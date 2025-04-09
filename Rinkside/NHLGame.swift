//
//  NHLGame.swift
//  Rinkside
//
//  Created by Nik Bar on 12/22/24.
//
import SwiftUI

struct NHLGame: Codable, CustomStringConvertible {
    let id: Int
    let season: Int
    let gameType: Int
    let gameDate: String
    let venue: NHLType
    let neutralSite: Bool
    let startTimeUTC: String
    let easternUTCOffset: String
    let venueUTCOffset: String
    let venueTimezone: String
    let gameState: String
    let gameScheduleState: String
    let tvBroadcasts: [NHLTVBroadcast]
    let awayTeam: NHLGameTeamDescription
    let homeTeam: NHLGameTeamDescription
    let periodDescriptor: NHLPeriodDescriptor?
    let gameOutcome: NHLGameOutcome?
    let winningGoalie: NHLGameWinningPlayer?
    let winningGoalScorer: NHLGameWinningPlayer?
    let threeMinuteRecap: String?
    let threeMinuteRecapFr: String?
    let condensedGame: String?
    let condensedGameFr: String?
    let gameCenterLink: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case season = "season"
        case gameType = "gameType"
        case gameDate = "gameDate"
        case venue = "venue"
        case neutralSite = "neutralSite"
        case startTimeUTC = "startTimeUTC"
        case easternUTCOffset = "easternUTCOffset"
        case venueUTCOffset = "venueUTCOffset"
        case venueTimezone = "venueTimezone"
        case gameState = "gameState"
        case gameScheduleState = "gameScheduleState"
        case awayTeam = "awayTeam"
        case homeTeam = "homeTeam"
        case periodDescriptor = "periodDescriptor"
        case gameOutcome = "gameOutcome"
        case winningGoalie = "winningGoalie"
        case winningGoalScorer = "winningGoalScorer"
        case threeMinuteRecap = "threeMinuteRecap"
        case gameCenterLink = "gameCenterLink"
        case threeMinuteRecapFr = "threeMinuteRecapFr"
        case condensedGame = "condensedGame"
        case condensedGameFr = "condensedGameFr"
        case tvBroadcasts = "tvBroadcasts"
    }
    
    var description: String {
        return "\(id)"
    }
    
}

struct NHLGameTeamDescription: Codable, CustomStringConvertible {
    let id: Int
    let commonName: NHLType
    let placeName: NHLType
    let placeNameWithPreposition: NHLType
    let abbrev: String
    let logo: String
    let darkLogo: String
    let homeSplitSquad: Bool?
    let awaySplitSquad: Bool?
    let score: Int?
    let radioLink: String?
    let hotelLink: String?
    let hotelDesc: String?
    let airlineLink: String?
    let airlineDesc: String?
    let ticketsLink: String?
    let ticketsLinkFr: String?
    let sog: Int?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case commonName = "commonName"
        case placeName = "placeName"
        case placeNameWithPreposition = "placeNameWithPreposition"
        case abbrev = "abbrev"
        case logo = "logo"
        case darkLogo = "darkLogo"
        case homeSplitSquad = "homeSplitSquad"
        case awaySplitSquad = "awaySplitSquad"
        case score = "score"
        case radioLink = "radioLink"
        case hotelLink = "hotelLink"
        case hotelDesc = "hotelDesc"
        case airlineLink = "airlineLink"
        case airlineDesc = "airlineDesc"
        case ticketsLink = "ticketsLink"
        case ticketsLinkFr = "ticketsLinkFr"
        case sog = "sog"
    }
    
    var description: String {
        return "\(commonName)"
    }
    
}

struct NHLPeriodDescriptor: Codable, CustomStringConvertible {
    let number: Int?
    let periodType: String
    let maxRegulationPeriods: Int
    
    enum CodingKeys: String, CodingKey {
        case number = "number"
        case periodType = "periodType"
        case maxRegulationPeriods = "maxRegulationPeriods"
    }
    
    var description: String {
        return "\(periodType)"
    }
}

struct NHLGameOutcome: Codable, CustomStringConvertible {
    let lastPeriodType: String
    
    enum CodingKeys: String, CodingKey {
        case lastPeriodType = "lastPeriodType"
    }
    
    var description: String {
        return "\(lastPeriodType)"
    }
}

struct NHLGameWinningPlayer: Codable, CustomStringConvertible {
    let playerId: Int
    let firstInitial: NHLType
    let lastName: NHLType
    
    enum CodingKeys: String, CodingKey {
        case playerId = "playerId"
        case firstInitial = "firstInitial"
        case lastName = "lastName"
    }
    
    var description: String {
        return "\(firstInitial) \(lastName)"
    }
}

struct NHLTVBroadcast: Codable, CustomStringConvertible {
    let id: Int
    let market: String
    let countryCode: String
    let network: String
    let sequenceNumber: Int
    
    enum CodningKeys: String, CodingKey {
        case id = "id"
        case market = "market"
        case countryCode = "countryCode"
        case network = "network"
        case sequenceNumber = "sequenceNumber"
    }
    
    var description: String {
        return "\(id)"
    }
}
