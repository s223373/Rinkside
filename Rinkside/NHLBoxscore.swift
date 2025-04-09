//
//  NHLBoxscore.swift
//  Rinkside
//
//  Created by Nik Bar on 1/6/25.
//
struct NHLBoxscore: Codable, CustomStringConvertible {
    let id: Int
    let season: Int
    let gameType: Int
    let limitedScoring: Bool
    let gameDate: String
    let venue: NHLType
    let venueLocation: NHLType
    let startTimeUTC: String
    let easternUTCOffset: String
    let venueUTCOffset: String
    let tvBroadcasts: [NHLTVBroadcast]
    let gameState: String
    let gameScheduleState: String
    let periodDescriptor: NHLPeriodDescriptor
    let regPeriods: Int
    let awayTeam: NHLGameTeamDescription
    let homeTeam: NHLGameTeamDescription
    let clock: NHLClock
    let playerByGameStats: NHLPlayerByGameStats
    let gameOutcome: NHLGameOutcome?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case season = "season"
        case gameType = "gameType"
        case limitedScoring = "limitedScoring"
        case gameDate = "gameDate"
        case venue = "venue"
        case venueLocation = "venueLocation"
        case startTimeUTC = "startTimeUTC"
        case easternUTCOffset = "easternUTCOffset"
        case venueUTCOffset = "venueUTCOffset"
        case tvBroadcasts = "tvBroadcasts"
        case gameState = "gameState"
        case gameScheduleState = "gameScheduleState"
        case periodDescriptor = "periodDescriptor"
        case regPeriods = "regPeriods"
        case awayTeam = "awayTeam"
        case homeTeam = "homeTeam"
        case clock = "clock"
        case playerByGameStats = "playerByGameStats"
        case gameOutcome = "gameOutcome"
    }
    
    var description: String {
        return "\(id)"
    }

}

struct NHLClock: Codable, CustomStringConvertible {
    let timeRemaining: String
    let secondsRemaining: Int
    let running: Bool
    let inIntermission: Bool
    
    enum CodingKeys: String, CodingKey {
        case timeRemaining = "timeRemaining"
        case secondsRemaining = "secondsRemaining"
        case running = "running"
        case inIntermission = "inIntermission"
    }
    
    var description: String {
        return "\(timeRemaining) \(secondsRemaining) \(running) \(inIntermission)"
    }
}

struct NHLPlayerByGameStats: Codable, CustomStringConvertible {
    let playerId: Int
    let sweaterNumber: Int
    let name: NHLType
    let position: String
    let goals: Int?
    let assists: Int?
    let points: Int?
    let plusMinus: Int?
    let pim: Int?
    let hits: Int?
    let powerPlayGoals: Int?
    let sog: Int?
    let faceoffWinningPctg: Double?
    let toi: String?
    let blockedShots: Int?
    let shifts: Int?
    let giveaways: Int?
    let takeaways: Int?
    let evenStrengthShotsAgainst: String?
    let powerPlayShotsAgainst: String?
    let shorthandedShotsAgainst: String?
    let saveShotsAgainst: String?
    let savePctg: Double?
    let evenStrengthGoalsAgainst: Int?
    let powerPlayGoalsAgainst: Int?
    let shorthandedGoalsAgainst: Int?
    let goalsAgainst: Int?
    let starter: Bool?
    let decision: String?
    let shotsAgainst: Int?
    let saves: Int?
    
    enum CodingKeys: String, CodingKey {
        case playerId = "playerId"
        case sweaterNumber = "sweaterNumber"
        case name = "name"
        case position = "position"
        case goals = "goals"
        case assists = "assists"
        case points = "points"
        case plusMinus = "plusMinus"
        case pim = "pim"
        case hits = "hits"
        case powerPlayGoals = "powerPlayGoals"
        case sog = "sog"
        case faceoffWinningPctg = "faceoffWinningPctg"
        case toi = "toi"
        case blockedShots = "blockedShots"
        case shifts = "shifts"
        case giveaways = "giveaways"
        case takeaways = "takeaways"
        case evenStrengthShotsAgainst = "evenStrengthShotsAgainst"
        case powerPlayShotsAgainst = "powerPlayShotsAgainst"
        case shorthandedShotsAgainst = "shorthandedShotsAgainst"
        case saveShotsAgainst = "saveShotsAgainst"
        case savePctg = "savePctg"
        case evenStrengthGoalsAgainst = "evenStrengthGoalsAgainst"
        case powerPlayGoalsAgainst = "powerPlayGoalsAgainst"
        case shorthandedGoalsAgainst = "shorthandedGoalsAgainst"
        case goalsAgainst = "goalsAgainst"
        case starter = "starter"
        case decision = "decision"
        case shotsAgainst = "shotsAgainst"
        case saves = "saves"
    }
    
    var description: String {
        return "\(playerId) \(name) \(position)"
    }
}

struct NHLBoxscorePlayerStats: Codable, CustomStringConvertible {
    let awayTeam: NHLBoxscoreTeamStats
    let homeTeam: NHLBoxscoreTeamStats
    
    enum CodingKeys: String, CodingKey {
        case awayTeam = "awayTeam"
        case homeTeam = "homeTeam"
    }
    
    var description: String {
        return "\(awayTeam)\n\(homeTeam)"
    }
}

struct NHLBoxscoreTeamStats: Codable, CustomStringConvertible {
    let forwards: [NHLPlayerByGameStats]
    let defensemen: [NHLPlayerByGameStats]
    let goalies: [NHLPlayerByGameStats]
    
    enum CodingKeys: String, CodingKey {
        case forwards = "forwards"
        case defensemen = "defensemen"
        case goalies = "goalies"
    }
    
    var description: String {
        return "\(forwards)\n\(defensemen)\n\(goalies)"
    }
}


