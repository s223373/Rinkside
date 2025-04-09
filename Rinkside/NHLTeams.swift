//
//  NHLTeams.swift
//  Rinkside
//
//  Created by Nik Bar on 11/24/24.
//
import SwiftUI

struct NHLTeams: Codable, CustomStringConvertible {
    let data: [NHLTeam]
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
    var description: String {
        return "\(data)"
    }
}

struct NHLTeam: Codable, Identifiable, CustomStringConvertible {
    
    let id: Int
    let franchiseId: Int?
    let fullName: String
    let leagueId: Int
    let rawTricode: String
    let triCode: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case franchiseId = "franchiseId"
        case fullName = "fullName"
        case leagueId = "leagueId"
        case rawTricode = "rawTricode"
        case triCode = "triCode"
    }
    
    var description: String {
        return "\(id): " + fullName
    }
    
}
