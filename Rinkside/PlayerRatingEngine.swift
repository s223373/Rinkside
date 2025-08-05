//
//  PlayerRatingEngine.swift
//  Rinkside
//
//  Created by Nik Bar on 5/17/25.
//

import Foundation

struct PlayerRatingEngine {
    static func calculateRawSkaterScore(for season: NHLSeasonTotal, position: String?) -> Double {
        let goals = Double(season.goals ?? 0)
        let assists = Double(season.assists ?? 0)
        let plusMinus = Double(season.plusMinus ?? 0)
        let gamesPlayed = Double(season.gamesPlayed ?? 0)
        let pim = Double(season.pim ?? 0)
        
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
            
            // ...but add a **bonus if they are high-scoring**
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


    
    static func calculateRawGoalieScore(for season: NHLSeasonTotal) -> Double {
        let savePct = season.savePctg ?? 0.0
        let gaa = season.goalsAgainstAvg ?? 0.0
        let shutouts = Double(season.shutouts ?? 0)
        let gamesPlayed = Double(season.gamesPlayed ?? 0)
        
        guard gamesPlayed > 0 else { return 0 }
        
        // Focus on per-game performance metrics
        let shutoutsPerGame = shutouts / gamesPlayed
        
        // Primary goalie metrics (save percentage is king)
        let savePerformance = savePct * 1000.0
        let goalsAgainstPenalty = gaa * 50.0
        let shutoutBonus = shutoutsPerGame * 150.0
        
        // Minimal games played factor (much smaller than before)
        let gamePlayedBonus = min(gamesPlayed * 0.5, 25.0)
        
        return savePerformance - goalsAgainstPenalty + shutoutBonus + gamePlayedBonus
    }
    
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
