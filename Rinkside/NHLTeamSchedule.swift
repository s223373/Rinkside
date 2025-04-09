//
//  NHLTeamSchedule.swift
//  Rinkside
//
//  Created by Nik Bar on 12/22/24.
//
import SwiftUI

struct NHLTeamSchedule: Codable, CustomStringConvertible {
    let previousSeason: Int
    let currentSeason: Int
    let clubTimezone: String
    let clubUTCOffset: String
    let games: [NHLGame]
    
    enum CodingKeys: String, CodingKey {
        case previousSeason = "previousSeason"
        case currentSeason = "currentSeason"
        case clubTimezone = "clubTimezone"
        case clubUTCOffset = "clubUTCOffset"
        case games = "games"
    }
    
    var description: String {
        return "NHLTeamSchedule"
    }
}
