// Updated PlayerRatingEngine.swift with multi-team season support
import Foundation

struct PlayerRatingEngine {
    
    // MARK: - Main Rating Calculation Methods
    
    static func calculateRawSkaterScore(for seasons: [NHLSeasonTotal], position: String?) -> Double {
        // Combine all season totals for the same season year
        let combinedStats = combineSeasonTotals(seasons)
        
        let goals = Double(combinedStats.goals ?? 0)
        let assists = Double(combinedStats.assists ?? 0)
        let plusMinus = Double(combinedStats.plusMinus ?? 0)
        let gamesPlayed = Double(combinedStats.gamesPlayed ?? 0)
        let pim = Double(combinedStats.pim ?? 0)
        
        guard gamesPlayed > 0 else { return 0 }

        // Per-game stats
        let goalsPerGame = goals / gamesPlayed
        let assistsPerGame = assists / gamesPlayed
        let pointsPerGame = goalsPerGame + assistsPerGame

        // Position-aware weightings
        let isDefenseman = position?.uppercased().contains("D") ?? false
        
        // Adjust weights for D-men vs Forwards
        var offenseWeight: Double
        if isDefenseman {
            // De-emphasize offense baseline...
            offenseWeight = (goalsPerGame * 60.0 + assistsPerGame * 50.0 + pointsPerGame * 20.0)
            
            // ...but add a bonus if they are high-scoring
            let offensiveDefensemanBonus = pointsPerGame >= 0.6 ? pow(pointsPerGame, 2.0) * 40.0 : 0.0
            offenseWeight += offensiveDefensemanBonus
        } else {
            // Forwards: standard emphasis
            offenseWeight = (goalsPerGame * 80.0 + assistsPerGame * 60.0 + pointsPerGame * 40.0)
        }
        
        // Defense and discipline
        let defense = (plusMinus / gamesPlayed) * 15.0
        let discipline = -(pim / gamesPlayed) * 8.0
        let gamePlayedBonus = min(gamesPlayed * 0.15, 10.0)

        return offenseWeight + defense + discipline + gamePlayedBonus
    }

    // Overloaded method for single season (backward compatibility)
    static func calculateRawSkaterScore(for season: NHLSeasonTotal, position: String?) -> Double {
        return calculateRawSkaterScore(for: [season], position: position)
    }
    
    static func calculateRawGoalieScore(for seasons: [NHLSeasonTotal]) -> Double {
        // Combine all season totals for goalies
        let combinedStats = combineGoalieSeasonTotals(seasons)
        
        let savePct = combinedStats.savePct
        let gaa = combinedStats.gaa
        let shutouts = Double(combinedStats.shutouts)
        let gamesPlayed = Double(combinedStats.gamesPlayed)
        
        guard gamesPlayed > 0 else { return 0 }
        
        // Focus on per-game performance metrics
        let shutoutsPerGame = shutouts / gamesPlayed
        
        // Primary goalie metrics (save percentage is king)
        let savePerformance = savePct * 1000.0
        let goalsAgainstPenalty = gaa * 50.0
        let shutoutBonus = shutoutsPerGame * 150.0
        
        // Minimal games played factor
        let gamePlayedBonus = min(gamesPlayed * 0.5, 25.0)
        
        return savePerformance - goalsAgainstPenalty + shutoutBonus + gamePlayedBonus
    }

    // Overloaded method for single season (backward compatibility)
    static func calculateRawGoalieScore(for season: NHLSeasonTotal) -> Double {
        return calculateRawGoalieScore(for: [season])
    }
    
    // MARK: - Season Combination Logic
    
    private static func combineSeasonTotals(_ seasons: [NHLSeasonTotal]) -> NHLSeasonTotal {
        guard !seasons.isEmpty else {
            return NHLSeasonTotal(gameTypeId: 2, gamesPlayed: 0, goalsAgainstAvg: 0, goalsAgainst: 0, leagueAbbrev: "NHL", savePctg: 0, season: 20242025, sequence: 1, losses: 0, wins: 0, ties: 0, timeOnIce: nil, shutouts: 0, teamName: nil, assists: 0, goals: 0, points: 0, pim: 0, otLosses: 0, teamPlaceNameWithPreposition: nil, plusMinus: 0, gamesStarted: 0)
        }
        
        // Filter to current season only (20242025)
        let currentSeasonStats = seasons.filter { $0.season == 20242025 }
        guard !currentSeasonStats.isEmpty else { return seasons.first! }
        
        // Sum up all the counting stats
        let combinedGamesPlayed = currentSeasonStats.compactMap { $0.gamesPlayed }.reduce(0, +)
        let combinedGoals = currentSeasonStats.compactMap { $0.goals }.reduce(0, +)
        let combinedAssists = currentSeasonStats.compactMap { $0.assists }.reduce(0, +)
        let combinedPoints = currentSeasonStats.compactMap { $0.points }.reduce(0, +)
        let combinedPIM = currentSeasonStats.compactMap { $0.pim }.reduce(0, +)
        let combinedPlusMinus = currentSeasonStats.compactMap { $0.plusMinus }.reduce(0, +)
        
        // Use the most recent team info (last entry)
        let mostRecentTeam = currentSeasonStats.last!
        
        return NHLSeasonTotal(
            gameTypeId: mostRecentTeam.gameTypeId,
            gamesPlayed: combinedGamesPlayed > 0 ? combinedGamesPlayed : nil,
            goalsAgainstAvg: mostRecentTeam.goalsAgainstAvg,
            goalsAgainst: mostRecentTeam.goalsAgainst,
            leagueAbbrev: mostRecentTeam.leagueAbbrev,
            savePctg: mostRecentTeam.savePctg,
            season: mostRecentTeam.season,
            sequence: mostRecentTeam.sequence,
            losses: mostRecentTeam.losses,
            wins: mostRecentTeam.wins,
            ties: mostRecentTeam.ties,
            timeOnIce: mostRecentTeam.timeOnIce,
            shutouts: mostRecentTeam.shutouts,
            teamName: mostRecentTeam.teamName,
            assists: combinedAssists > 0 ? combinedAssists : nil,
            goals: combinedGoals > 0 ? combinedGoals : nil,
            points: combinedPoints > 0 ? combinedPoints : nil,
            pim: combinedPIM > 0 ? combinedPIM : nil,
            otLosses: mostRecentTeam.otLosses,
            teamPlaceNameWithPreposition: mostRecentTeam.teamPlaceNameWithPreposition,
            plusMinus: combinedPlusMinus != 0 ? combinedPlusMinus : nil,
            gamesStarted: mostRecentTeam.gamesStarted
        )
    }
    
    private static func combineGoalieSeasonTotals(_ seasons: [NHLSeasonTotal]) -> (savePct: Double, gaa: Double, shutouts: Int, gamesPlayed: Int) {
        guard !seasons.isEmpty else { return (0, 0, 0, 0) }
        
        // Filter to current season only
        let currentSeasonStats = seasons.filter { $0.season == 20242025 }
        guard !currentSeasonStats.isEmpty else {
            let first = seasons.first!
            return (first.savePctg ?? 0, first.goalsAgainstAvg ?? 0, first.shutouts ?? 0, first.gamesPlayed ?? 0)
        }
        
        // For goalies, we need to calculate weighted averages for percentage stats
        let totalGamesPlayed = currentSeasonStats.compactMap { $0.gamesPlayed }.reduce(0, +)
        let totalShutouts = currentSeasonStats.compactMap { $0.shutouts }.reduce(0, +)
        
        // Calculate weighted save percentage and GAA
        var weightedSavePct = 0.0
        var weightedGAA = 0.0
        var totalWeight = 0.0
        
        for season in currentSeasonStats {
            let games = Double(season.gamesPlayed ?? 0)
            if games > 0, let savePct = season.savePctg, let gaa = season.goalsAgainstAvg {
                weightedSavePct += savePct * games
                weightedGAA += gaa * games
                totalWeight += games
            }
        }
        
        let finalSavePct = totalWeight > 0 ? weightedSavePct / totalWeight : 0
        let finalGAA = totalWeight > 0 ? weightedGAA / totalWeight : 0
        
        return (finalSavePct, finalGAA, totalShutouts, totalGamesPlayed)
    }
    
    // MARK: - Existing Methods (unchanged)
    
    static func scaleToRating(rawScore: Double, mean: Double, stdDev: Double) -> Int {
        guard stdDev > 0 else { return 84 }

        let zScore = (rawScore - mean) / stdDev

        // Adjust scaling factor to create more separation
        let scaled = 77 + (zScore * 5)

        return Int(max(60, min(99, round(scaled))))
    }
    
    static func playerTier(from rating: Int) -> String {
        switch rating {
        case 90...: return "Superstar"
        case 85..<90: return "Elite"
        case 80..<85: return "Top 6 F / Top 4 D"
        case 75..<80: return "Depth"
        case 70..<75: return "Fringe"
        default: return "Replacement"
        }
    }
}

// MARK: - Helpers for Stats Arrays

extension Array where Element == Double {
    func average() -> Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
    
    func standardDeviation() -> Double {
        let mean = self.average()
        let variance = map { pow($0 - mean, 2.0) }.reduce(0, +) / Double(count)
        return sqrt(variance)
    }
}
