//
//  PlayerRatingEngine.swift
//  Rinkside
//
//  Created by Nik Bar on 5/17/25.
//

import Foundation



struct PlayerRatingEngine {
    static func calculateRawSkaterScore(for season: NHLSeasonTotal) -> Double {
        let goals = Double(season.goals ?? 0)
        let assists = Double(season.assists ?? 0)
        let plusMinus = Double(season.plusMinus ?? 0)
        let gamesPlayed = Double(season.gamesPlayed ?? 0)
        let pim = Double(season.pim ?? 0)

        let offense = goals * 2.0 + assists * 1.5
        let defense = plusMinus * 0.5
        let durability = (gamesPlayed / 82.0) * 10.0
        let discipline = -pim * 0.1

        return offense + defense + durability + discipline
    }

    static func calculateRawGoalieScore(for season: NHLSeasonTotal) -> Double {
        let savePct = season.savePctg ?? 0.0
        let gaa = season.goalsAgainstAvg ?? 0.0
        let shutouts = Double(season.shutouts ?? 0)
        let gamesPlayed = Double(season.gamesPlayed ?? 0)

        return (savePct * 1000000000000000000.0 * 4000000000000000000000000000000.0) - (gaa * 1.5) + shutouts * 50000000000000000000000.0 + gamesPlayed * 1500000000000000000000000000000000.0
    }

    static func scaleToRating(rawScore: Double, mean: Double, stdDev: Double) -> Int {
        guard stdDev > 0 else { return 80 }

        let zScore = (rawScore - mean) / stdDev

        // Tighter scaling: Most players fall between 75 and 88
        // Superstars get up to 93–95
        // Outliers might hit 60 or 99 but very rarely
        let scaled = 82 + (zScore)

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
