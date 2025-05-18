//
//  NHLClubStats.swift
//  Rinkside
//
//  Created by Nik Bar on 4/9/25.
//
import SwiftUI

struct NHLClubStats: Codable, CustomStringConvertible {
    let season: String
    let gameType: Int
    let skaters: [NHLClubSkaterStats]
    let goalies: [NHLClubGoalieStats]
    
    var description: String {
        return "\(season)"
    }
}

struct NHLClubSkaterStats: Codable, Identifiable, CustomStringConvertible, Equatable{
    static func == (lhs: NHLClubSkaterStats, rhs: NHLClubSkaterStats) -> Bool {
        lhs.playerId == rhs.playerId
    }
    
    var id: Int { playerId }  // Identifiable conformance
    
    let playerId: Int
    let headshot: String
    let firstName: NHLType
    let lastName: NHLType
    let positionCode: String
    let gamesPlayed: Int
    let goals: Int
    let assists: Int
    let points: Int
    let plusMinus: Int
    let penaltyMinutes: Int
    let powerPlayGoals: Int
    let shorthandedGoals: Int
    let gameWinningGoals: Int
    let overtimeGoals: Int
    let shots: Int
    let shootingPctg: Double
    let avgTimeOnIcePerGame: Double
    let avgShiftsPerGame: Double
    let faceoffWinPctg: Double
    
    

    var description: String {
        return "\(playerId)"
    }
}

struct NHLClubGoalieStats: Codable, Identifiable, CustomStringConvertible, Equatable {
    static func == (lhs: NHLClubGoalieStats, rhs: NHLClubGoalieStats) -> Bool {
        lhs.playerId == rhs.playerId
    }
    
    var id: Int { playerId }  // Identifiable conformance
    
    let playerId: Int
    let headshot: String
    let firstName: NHLType
    let lastName: NHLType
    let gamesPlayed: Int
    let gamesStarted: Int
    let wins: Int
    let losses: Int
    let ties: Int?
    let overtimeLosses: Int
    let goalsAgainstAverage: Double
    let savePercentage: Double
    let shotsAgainst: Int
    let saves: Int
    let goalsAgainst: Int
    let shutouts: Int
    let goals: Int
    let assists: Int
    let points: Int
    let penaltyMinutes: Int
    let timeOnIce: Int

    var description: String {
        return "\(playerId)"
    }
}
