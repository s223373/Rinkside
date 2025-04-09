//
//  NHLStats.swift
//  Rinkside
//
//  Created by Nik Bar on 12/26/24.
//
import SwiftUI

struct NHLStats: Codable, CustomStringConvertible {
    let assists: Int?
    let gameWinningGoals: Int?
    let gamesPlayed: Int?
    let goals: Int?
    let otGoals: Int?
    let points: Int?
    let pim: Int?
    let plusMinus: Int?
    let powerPlayGoals: Int?
    let powerPlayPoints: Int?
    let shootingPctg: Double?
    let shorthandedGoals: Int?
    let shorthandedPoints: Int?
    let shots: Int?
    let avgToi: String?
    let gamesStarted: Int?
    let goalsAgainst: Int?
    let goalsAgainstAvg: Double?
    let losses: Int?
    let otLosses: Int?
    let savePctg: Double?
    let shotsAgainst: Int?
    let shutouts: Int?
    let timeOnIce: String?
    let wins: Int?
    
    enum CodingKeys: String, CodingKey {
        case assists = "assists"
        case gameWinningGoals = "gameWinningGoals"
        case gamesPlayed = "gamesPlayed"
        case goals = "goals"
        case otGoals = "otGoals"
        case points = "points"
        case pim = "pim"
        case plusMinus = "plusMinus"
        case powerPlayGoals = "powerPlayGoals"
        case powerPlayPoints = "powerPlayPoints"
        case shootingPctg = "shootingPctg"
        case shorthandedGoals = "shorthandedGoals"
        case shorthandedPoints = "shorthandedPoints"
        case shots = "shots"
        case avgToi = "avgToi"
        case gamesStarted = "gamesStarted"
        case goalsAgainst = "goalsAgainst"
        case goalsAgainstAvg = "goalsAgainstAvg"
        case losses = "losses"
        case otLosses = "otLosses"
        case savePctg = "savePctg"
        case shotsAgainst = "shotsAgainst"
        case shutouts = "shutouts"
        case timeOnIce = "timeOnIce"
        case wins = "wins"
    }
    
    var description: String {
        return "Points: \(points), Goals: \(goals), Assists: \(assists)"
    }
}

struct NHLPlayerFeaturedStats: Codable, CustomStringConvertible {
    let season: Int
    let regularSeason: NHLPlayerFeaturedStatsRegularSeason
    
    enum CodingKeys: String, CodingKey {
        case season = "season"
        case regularSeason = "regularSeason"
    }
    
    var description: String {
        "\(season)\n\(regularSeason)"
    }
}

struct NHLPlayerFeaturedStatsRegularSeason: Codable, CustomStringConvertible {
    let subSeason: NHLStats
    let career: NHLStats
    
    enum CodingKeys: String, CodingKey {
        case subSeason = "subSeason"
        case career = "career"
    }
    
    var description: String {
        "\(subSeason)\n\(career)"
    }
}

struct NHLPlayerCareerTotals: Codable, CustomStringConvertible {
    let regularSeason: NHLStats
    let playoffs: NHLStats?
    
    enum CodingKeys: String, CodingKey {
        case regularSeason = "regularSeason"
        case playoffs = "playoffs"
    }
    
    var description: String {
        "\(regularSeason)\n\(playoffs)"
    }
}
