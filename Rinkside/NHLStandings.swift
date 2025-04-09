//
//  NHLStandings.swift
//  Rinkside
//
//  Created by Nik Bar on 1/2/25.
//

struct NHLStandings: Codable, CustomStringConvertible {
    let wildcardIndicator: Bool?
    let standings: [NHLStandingsTeamStats]
    
    enum CodingKeys: String, CodingKey {
        case wildcardIndicator = "wildcardIndicator"
        case standings = "standings"
    }
    
    var description: String {
        return "NHLStandings" 
    }
}

struct NHLStandingsTeamStats: Codable, CustomStringConvertible {
    let conferenceAbbrev: String
    let conferenceHomeSequence: Int
    let conferenceL10Sequence: Int
    let conferenceName: String
    let conferenceRoadSequence: Int
    let conferenceSequence: Int
    let date: String
    let divisionAbbrev: String
    let divisionHomeSequence: Int
    let divisionL10Sequence: Int
    let divisionName: String
    let divisionRoadSequence: Int
    let divisionSequence: Int
    let gameTypeId: Int
    let gamesPlayed: Int
    let goalDifferential: Int
    let goalDifferentialPctg: Double
    let goalsAgainst: Int?
    let goalsFor: Int?
    let goalsForPctg: Double?
    let homeGamesPlayed: Int?
    let homeGoalDifferential: Int?
    let homeGoalsAgainst: Int?
    let homeGoalsFor: Int?
    let homeLosses: Int?
    let homeOtLosses: Int?
    let homePoints: Int?
    let homeRegulationPlusOtWins: Int?
    let homeRegulationWins: Int?
    let homeTies: Int?
    let homeWins: Int?
    let l10GamesPlayed: Int?
    let l10GoalDifferential: Int?
    let l10GoalsAgainst: Int?
    let l10GoalsFor: Int?
    let l10Losses: Int?
    let l10OtLosses: Int?
    let l10Points: Int?
    let l10RegulationPlusOtWins: Int?
    let l10RegulationWins: Int?
    let l10Ties: Int?
    let l10Wins: Int?
    let leagueHomeSequence: Int?
    let leagueL10Sequence: Int?
    let leagueRoadSequence: Int?
    let leagueSequence: Int?
    let losses: Int?
    let otLosses: Int?
    let placeName: NHLType?
    let pointcPctg: Double?
    let points: Int?
    let regulationPlusOtWinPctg: Double?
    let regulationPlusOtWins: Int?
    let regulationWinPctg: Double?
    let regulationWins: Int?
    let roadGamesPlayed: Int?
    let roadGoalDifferential: Int?
    let roadGoalsAgainst: Int?
    let roadGoalsFor: Int?
    let roadLosses: Int?
    let roadOtLosses: Int?
    let roadPoints: Int?
    let roadRegulationPlusOtWins: Int?
    let roadRegulationWins: Int?
    let roadTies: Int?
    let roadWins: Int?
    let seasonId: Int?
    let shootoutLosses: Int?
    let shootoutWins: Int?
    let streakCode: String?
    let streakCount: Int?
    let teamName: NHLType?
    let teamCommonName: NHLType?
    let teamAbbrev: NHLType?
    let teamLogo: String?
    let ties: Int?
    let waiversSequence: Int?
    let wildcardSequence: Int?
    let winPctg: Double?
    let wins: Int?
    
    
    enum CodingKeys: String, CodingKey {
            case conferenceAbbrev = "conferenceAbbrev"
            case conferenceHomeSequence = "conferenceHomeSequence"
            case conferenceL10Sequence = "conferenceL10Sequence"
            case conferenceName = "conferenceName"
            case conferenceRoadSequence = "conferenceRoadSequence"
            case conferenceSequence = "conferenceSequence"
            case date = "date"
            case divisionAbbrev = "divisionAbbrev"
            case divisionHomeSequence = "divisionHomeSequence"
            case divisionL10Sequence = "divisionL10Sequence"
            case divisionName = "divisionName"
            case divisionRoadSequence = "divisionRoadSequence"
            case divisionSequence = "divisionSequence"
            case gameTypeId = "gameTypeId"
            case gamesPlayed = "gamesPlayed"
            case goalDifferential = "goalDifferential"
            case goalDifferentialPctg = "goalDifferentialPctg"
            case goalsAgainst = "goalsAgainst"
            case goalsFor = "goalsFor"
            case goalsForPctg = "goalsForPctg"
            case homeGamesPlayed = "homeGamesPlayed"
            case homeGoalDifferential = "homeGoalDifferential"
            case homeGoalsAgainst = "homeGoalsAgainst"
            case homeGoalsFor = "homeGoalsFor"
            case homeLosses = "homeLosses"
            case homeOtLosses = "homeOtLosses"
            case homePoints = "homePoints"
            case homeRegulationPlusOtWins = "homeRegulationPlusOtWins"
            case homeRegulationWins = "homeRegulationWins"
            case homeTies = "homeTies"
            case homeWins = "homeWins"
            case l10GamesPlayed = "l10GamesPlayed"
            case l10GoalDifferential = "l10GoalDifferential"
            case l10GoalsAgainst = "l10GoalsAgainst"
            case l10GoalsFor = "l10GoalsFor"
            case l10Losses = "l10Losses"
            case l10OtLosses = "l10OtLosses"
            case l10Points = "l10Points"
            case l10RegulationPlusOtWins = "l10RegulationPlusOtWins"
            case l10RegulationWins = "l10RegulationWins"
            case l10Ties = "l10Ties"
            case l10Wins = "l10Wins"
            case leagueHomeSequence = "leagueHomeSequence"
            case leagueL10Sequence = "leagueL10Sequence"
            case leagueRoadSequence = "leagueRoadSequence"
            case leagueSequence = "leagueSequence"
            case losses = "losses"
            case otLosses = "otLosses"
            case placeName = "placeName"
            case pointcPctg = "pointcPctg"
            case points = "points"
            case regulationPlusOtWinPctg = "regulationPlusOtWinPctg"
            case regulationPlusOtWins = "regulationPlusOtWins"
            case regulationWinPctg = "regulationWinPctg"
            case regulationWins = "regulationWins"
            case roadGamesPlayed = "roadGamesPlayed"
            case roadGoalDifferential = "roadGoalDifferential"
            case roadGoalsAgainst = "roadGoalsAgainst"
            case roadGoalsFor = "roadGoalsFor"
            case roadLosses = "roadLosses"
            case roadOtLosses = "roadOtLosses"
            case roadPoints = "roadPoints"
            case roadRegulationPlusOtWins = "roadRegulationPlusOtWins"
            case roadRegulationWins = "roadRegulationWins"
            case roadTies = "roadTies"
            case roadWins = "roadWins"
            case seasonId = "seasonId"
            case shootoutLosses = "shootoutLosses"
            case shootoutWins = "shootoutWins"
            case streakCode = "streakCode"
            case streakCount = "streakCount"
            case teamName = "teamName"
            case teamCommonName = "teamCommonName"
            case teamAbbrev = "teamAbbrev"
            case teamLogo = "teamLogo"
            case ties = "ties"
            case waiversSequence = "waiversSequence"
            case wildcardSequence = "wildcardSequence"
            case winPctg = "winPctg"
            case wins = "wins"
        }
    
    var description: String {
        return "\(teamName?.def ?? "Unknown")"
    }
}
