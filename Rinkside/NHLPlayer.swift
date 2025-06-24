//
//  NHLPlayer.swift
//  Rinkside
//
//  Created by Nik Bar on 12/28/24.
//
import SwiftUI

struct NHLPlayer: Codable, CustomStringConvertible {
    let playerId: Int
    let isActive: Bool
    let currentTeamId: Int?
    let currentTeamAbbrev: String?
    let fullTeamName: NHLType?
    let teamCommonName: NHLType?
    let teamPlaceNameWithPreposition: NHLType?
    let firstName: NHLType
    let lastName: NHLType
    let teamLogo: String?
    let sweaterNumber: Int?
    let position: String
    let headshot: String
    let heroImage: String
    let heightInInches: Int
    let heightInCentimeters: Int
    let weightInPounds: Int
    let weightInKilograms: Int
    let birthDate: String?
    let birthCity: NHLType
    let birthStateProvince: NHLType?
    let birthCountry: String
    let shootsCatches: String
    let draftDetails: NHLDraftDetails?
    let playerSlug: String
    let inTop100AllTime: Int
    let inHHOF: Int
    let featuredStats: NHLPlayerFeaturedStats?
    let careerTotals: NHLPlayerCareerTotals?
    let shopLink: String
    let twitterLink: String
    let watchLink: String
    let last5Games: [NHLGameDetail]
    let seasonTotals: [NHLSeasonTotal]?
    let currentRoster: [NHLPersonShort]?
    
    enum CodingKeys: String, CodingKey {
        case playerId = "playerId"
        case isActive = "isActive"
        case currentTeamId = "currentTeamId"
        case currentTeamAbbrev = "currentTeamAbbrev"
        case fullTeamName = "fullTeamName"
        case teamCommonName = "teamCommonName"
        case teamPlaceNameWithPreposition = "teamPlaceNameWithPreposition"
        case firstName = "firstName"
        case lastName = "lastName"
        case teamLogo = "teamLogo"
        case sweaterNumber = "sweaterNumber"
        case position = "position"
        case headshot = "headshot"
        case heroImage = "heroImage"
        case heightInInches = "heightInInches"
        case heightInCentimeters = "heightInCentimeters"
        case weightInPounds = "weightInPounds"
        case weightInKilograms = "weightInKilograms"
        case birthDate = "birthDate"
        case birthCity = "birthCity"
        case birthStateProvince = "birthStateProvince"
        case birthCountry = "birthCountry"
        case shootsCatches = "shootsCatches"
        case draftDetails = "draftDetails"
        case playerSlug = "playerSlug"
        case inTop100AllTime = "inTop100AllTime"
        case inHHOF = "inHHOF"
        case featuredStats = "featuredStats"
        case careerTotals = "careerTotals"
        case shopLink = "shopLink"
        case twitterLink = "twitterLink"
        case watchLink = "watchLink"
        case last5Games = "last5Games"
        case seasonTotals = "seasonTotals"
        case currentRoster = "currentRoster"
    }
    
    var description: String {
        return "\(firstName) \(lastName)"
    }
    
}

struct NHLDraftDetails: Codable, CustomStringConvertible {
    let year: Int
    let teamAbbrev: String
    let round: Int
    let pickInRound: Int
    let overallPick: Int
    
    enum CodingKeys: String, CodingKey {
        case year = "year"
        case teamAbbrev = "teamAbbrev"
        case round = "round"
        case pickInRound = "pickInRound"
        case overallPick = "overallPick"
    }
    
    var description: String {
        "\(year) \(teamAbbrev) \(round) \(pickInRound) \(overallPick)"
    }
}

struct NHLGameDetail: Codable, CustomStringConvertible {
    let decision: String?
    let gameDate: String
    let gameId: Int
    let gameTypeId: Int
    let gamesStarted: Int?
    let goalsAgainst: Int?
    let homeRoadFlag: String
    let opponentAbbrev: String
    let penaltyMinutes: Int?
    let savePctg: Double?
    let shotsAgainst: Int?
    let teamAbbrev: String
    let toi: String
    let assists: Int?
    let goals: Int?
    let pim: Int?
    let plusMinus: Int?
    let points: Int?
    let powerPlayGoals: Int?
    let shifts: Int?
    let shorthandedGoals: Int?
    let shots: Int?
    
    enum CodingKeys: String, CodingKey {
        case decision = "decision"
        case gameDate = "gameDate"
        case gameId = "gameId"
        case gameTypeId = "gameTypeId"
        case gamesStarted = "gamesStarted"
        case goalsAgainst = "goalsAgainst"
        case homeRoadFlag = "homeRoadFlag"
        case opponentAbbrev = "opponentAbbrev"
        case penaltyMinutes = "penaltyMinutes"
        case savePctg = "savePctg"
        case shotsAgainst = "shotsAgainst"
        case teamAbbrev = "teamAbbrev"
        case toi = "toi"
        case assists = "assists"
        case goals = "goals"
        case pim = "pim"
        case plusMinus = "plusMinus"
        case points = "points"
        case powerPlayGoals = "powerPlayGoals"
        case shifts = "shifts"
        case shorthandedGoals = "shorthandedGoals"
        case shots = "shots"
    }
    
    var description: String {
        return "\(teamAbbrev) vs \(opponentAbbrev)"
    }
}

struct NHLSeasonTotal: Codable, CustomStringConvertible {
    
    let gameTypeId: Int?
    let gamesPlayed: Int?
    let goalsAgainstAvg: Double?
    let goalsAgainst: Int?
    let leagueAbbrev: String?
    let savePctg: Double?
    let season: Int?
    let sequence: Int?
    let losses: Int?
    let wins: Int?
    let ties: Int?
    let timeOnIce: String?
    let shutouts: Int?
    let teamName: NHLType?
    let assists: Int?
    let goals: Int?
    let points: Int?
    let pim: Int?
    let otLosses: Int?
    let teamPlaceNameWithPreposition: NHLType?
    let plusMinus: Int?
    let gamesStarted: Int?
    
    enum CodingKeys: String, CodingKey {
        case gameTypeId = "gameTypeId"
        case gamesPlayed = "gamesPlayed"
        case goalsAgainstAvg = "goalsAgainstAvg"
        case goalsAgainst = "goalsAgainst"
        case leagueAbbrev = "leagueAbbrev"
        case savePctg = "savePctg"
        case season = "season"
        case sequence = "sequence"
        case losses = "losses"
        case wins = "wins"
        case ties = "ties"
        case timeOnIce = "timeOnIce"
        case shutouts = "shutouts"
        case teamName = "teamName"
        case assists = "assists"
        case goals = "goals"
        case points = "points"
        case pim = "pim"
        case otLosses = "otLosses"
        case teamPlaceNameWithPreposition = "teamPlaceNameWithPreposition"
        case plusMinus = "plusMinus"
        case gamesStarted = "gamesStarted"
    }
    
    var description: String {
        return "\(teamName) - \(season) - \(sequence) - \(points) - \(goals) - \(assists)"
    }
}

struct NHLPersonShort: Codable, CustomStringConvertible {
    let playerId: Int
    let firstName: NHLType
    let lastName: NHLType
    let playerSlug: String
    
    enum CodingKeys: String, CodingKey {
        case playerId = "playerId"
        case firstName = "firstName"
        case lastName = "lastName"
        case playerSlug = "playerSlug"
    }
    
    var description: String {
        return "\(firstName) \(lastName)"
    }
}

struct NHLPlayerSkaterStats: Codable, CustomStringConvertible {
    let playerId: Int
    let firstName: NHLType
    let lastName: NHLType
    let sweaterNumber: Int?
    let headshot: String
    let teamAbbrev: String
    let teamName: NHLType
    let teamLogo: String
    let position: String
    let value: Double
    
    enum CodingKeys: String, CodingKey {
        case playerId = "id"
        case firstName = "firstName"
        case lastName = "lastName"
        case sweaterNumber = "sweaterNumber"
        case headshot = "headshot"
        case teamAbbrev = "teamAbbrev"
        case teamName = "teamName"
        case teamLogo = "teamLogo"
        case position = "position"
        case value = "value"
    }
    
    var description: String {
        return "\(playerId)"
    }
}

struct NHLPlayerSkaterStatsLeaders: Codable, CustomStringConvertible {
    let goals: [NHLPlayerSkaterStats]?
    let assists: [NHLPlayerSkaterStats]?
    let points: [NHLPlayerSkaterStats]?
    
    enum CodingKeys: String, CodingKey {
        case goals = "goals"
        case assists = "assists"
        case points = "points"
    }
    
    var description: String {
        return "\(goals?.first?.playerId ?? 0)"
    }
}

struct NHLPlayerGoalieStatsLeaders: Codable, CustomStringConvertible {
    let wins: [NHLPlayerSkaterStats]?
    let savePctg: [NHLPlayerSkaterStats]?
    let goalsAgainstAverage: [NHLPlayerSkaterStats]?
    
    enum CodingKeys: String, CodingKey {
        case wins = "wins"
        case savePctg = "savePctg"
        case goalsAgainstAverage = "goalsAgainstAverage"
    }
    
    var description: String {
        return "\(wins?.first?.playerId ?? 0)"
    }
}
