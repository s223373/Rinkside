//
//  NHLResource.swift
//  Rinkside
//
//  Created by Nik Bar on 11/24/24.
//

import Foundation

struct NHLResource {
    static var baseURL: String = "https://api.nhle.com/v1"
    static var baseRosterURL: String = "https://api-web.nhle.com/v1"
    static var baseStatsRestURL: String = "https://api.nhle.com/stats/rest"
    static var baseTeamLogoURL: String = "https://assets.nhle.com/logos/nhl/svg"
    
    static var currentNHLTeams: [String] = ["Carolina Hurricanes", "Columbus Blue Jackets", "New York Islanders", "New York Rangers", "Philadelphia Flyers", "Pittsburgh Penguins", "Washington Capitals", "New Jersey Devils", "Boston Bruins", "Montreal Canadiens", "Buffalo Sabres", "Detroit Red Wings", "Florida Panthers", "Toronto Maple Leafs", "Ottawa Senators", "Tampa Bay Lightning", "Chicago Blackhawks", "Colorado Avalanche", "Dallas Stars", "Minnesota Wild", "Nashville Predators", "St. Louis Blues", "Utah Hockey Club", "Winnipeg Jets", "Anaheim Ducks", "Calgary Flames", "Edmonton Oilers", "Los Angeles Kings", "San Jose Sharks", "Seattle Kraken", "Vancouver Canucks", "Vegas Golden Knights"]
    
    public static func teamsURL() -> URL? {
        return URL(string: "\(baseStatsRestURL)/en/team")
    }
    
    public static func currentRosterURL(for teamId: String, with seasonId: String) -> URL? {
        return URL(string: "\(baseRosterURL)/roster/\(teamId)/\(seasonId)")
    }
    
    public static func currentProspectsURL(for teamId: String) -> URL? {
        return URL(string: "\(baseRosterURL)/prospects/\(teamId)")
    }
    
    public static func baseTeamLogoLightURL(for teamId: String) -> URL? {
        return URL(string: "\(baseTeamLogoURL)/\(teamId)_light.svg")
    }
    
    public static func baseTeamLogoDarkURL(for teamId: String) -> URL? {
        return URL(string: "\(baseTeamLogoURL)/\(teamId)_dark.svg")
    }
    
    public static func baseTeamScheduleURL(for teamId: String) -> URL? {
        return URL(string: "\(baseRosterURL)/club-schedule-season/\(teamId)/20242025")
    }
    
    public static func basePlayerLandingURL(for playerId: Int) -> URL? {
        return URL(string: "\(baseRosterURL)/player/\(playerId)/landing")
    }
    
    public static func baseStandingsURL() -> URL? {
        return URL(string: "\(baseRosterURL)/standings/now")
    }
    
    public static func dateStandingsURL(for date: String) -> URL? {
        return URL(string: "\(baseRosterURL)/standings/\(date)")
    }
    
    public static func gamecenterURL(for gameId: Int) -> URL? {
        return URL(string: "\(baseRosterURL)/gamecenter/\(gameId)/boxscore")
    }
    
    public static func regularSeasonClubStatsURL(for teamId: String) -> URL? {
        return URL(string: "\(baseRosterURL)/club-stats/\(teamId)/20242025/2")
    }
    
    public static func skaterStatsLeadersURL(season: String, gameType: Int, statsType: String) -> URL? {
        return URL(string: "\(baseRosterURL)/skater-stats-leaders/\(season)/\(gameType)?categories=\(statsType)&limit=-1")
    }
    
    public static func goalieStatsLeadersURL(season: String, gameType: Int, statsType: String) -> URL? {
        return URL(string: "\(baseRosterURL)/goalie-stats-leaders/\(season)/\(gameType)?categories=\(statsType)&limit=-1")
    }
    
    public static func defaultNHLPlayer() -> NHLPlayer {
        return NHLPlayer(playerId: 0, isActive: false, currentTeamId: 0, currentTeamAbbrev: "NHL", fullTeamName: NHLType(def: ""), teamCommonName: NHLType(def: ""), teamPlaceNameWithPreposition: NHLType(def: ""), firstName: NHLType(def: ""), lastName: NHLType(def: ""), teamLogo: "", sweaterNumber: -1, position: "", headshot: "", heroImage: "", heightInInches: -1, heightInCentimeters: -1, weightInPounds: -1, weightInKilograms: -1, birthDate: "", birthCity: NHLType(def: ""), birthStateProvince: NHLType(def: ""), birthCountry: "", shootsCatches: "", draftDetails: NHLDraftDetails(year: -1, teamAbbrev: "", round: -1, pickInRound: -1, overallPick: -1), playerSlug: "", inTop100AllTime: -1, inHHOF: -1, featuredStats: NHLPlayerFeaturedStats(season: -1, regularSeason: NHLPlayerFeaturedStatsRegularSeason(subSeason: NHLStats(assists: -1, gameWinningGoals: -1, gamesPlayed: -1, goals: -1, otGoals: -1, points: -1, pim: -1, plusMinus: -1, powerPlayGoals: -1, powerPlayPoints: -1, shootingPctg: -1, shorthandedGoals: -1, shorthandedPoints: -1, shots: -1, avgToi: "", gamesStarted: -1, goalsAgainst: -1, goalsAgainstAvg: -1, losses: -1, otLosses: -1, savePctg: -1, shotsAgainst: -1, shutouts: -1, timeOnIce: "", wins: -1), career: NHLStats(assists: -1, gameWinningGoals: -1, gamesPlayed: -1, goals: -1, otGoals: -1, points: -1, pim: -1, plusMinus: -1, powerPlayGoals: -1, powerPlayPoints: -1, shootingPctg: -1, shorthandedGoals: -1, shorthandedPoints: -1, shots: -1, avgToi: "", gamesStarted: -1, goalsAgainst: -1, goalsAgainstAvg: -1, losses: -1, otLosses: -1, savePctg: -1, shotsAgainst: -1, shutouts: -1, timeOnIce: "", wins: -1))), careerTotals: NHLPlayerCareerTotals(regularSeason: NHLStats(assists: -1, gameWinningGoals: -1, gamesPlayed: -1, goals: -1, otGoals: -1, points: -1, pim: -1, plusMinus: -1, powerPlayGoals: -1, powerPlayPoints: -1, shootingPctg: -1, shorthandedGoals: -1, shorthandedPoints: -1, shots: -1, avgToi: "", gamesStarted: -1, goalsAgainst: -1, goalsAgainstAvg: -1, losses: -1, otLosses: -1, savePctg: -1, shotsAgainst: -1, shutouts: -1, timeOnIce: "", wins: -1), playoffs: NHLStats(assists: -1, gameWinningGoals: -1, gamesPlayed: -1, goals: -1, otGoals: -1, points: -1, pim: -1, plusMinus: -1, powerPlayGoals: -1, powerPlayPoints: -1, shootingPctg: -1, shorthandedGoals: -1, shorthandedPoints: -1, shots: -1, avgToi: "", gamesStarted: -1, goalsAgainst: -1, goalsAgainstAvg: -1, losses: -1, otLosses: -1, savePctg: -1, shotsAgainst: -1, shutouts: -1, timeOnIce: "", wins: -1)), shopLink: "", twitterLink: "", watchLink: "", last5Games: [NHLGameDetail(decision: "", gameDate: "", gameId: -1, gameTypeId: -1, gamesStarted: -1, goalsAgainst: -1, homeRoadFlag: "", opponentAbbrev: "", penaltyMinutes: -1, savePctg: -1, shotsAgainst: -1, teamAbbrev: "", toi: "", assists: -1, goals: -1, pim: -1, plusMinus: -1, points: -1, powerPlayGoals: -1, shifts: -1, shorthandedGoals: -1, shots: -1)], seasonTotals: [NHLSeasonTotal(gameTypeId: -1, gamesPlayed: -1, goalsAgainstAvg: -1, goalsAgainst: -1, leagueAbbrev: "", savePctg: -1, season: -1, sequence: -1, losses: -1, wins: -1, ties: -1, timeOnIce: "", shutouts: -1, teamName: NHLType(def: ""), assists: -1, goals: -1, points: -1, pim: -1, otLosses: -1, teamPlaceNameWithPreposition: NHLType(def: ""), plusMinus: -1, gamesStarted: -1)], currentRoster: [NHLPersonShort(playerId: -1, firstName: NHLType(def: ""), lastName: NHLType(def: ""), playerSlug: "")])
    }
    
    
}
