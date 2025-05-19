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
    
    public static func currentRosterURL(for teamId: String) -> URL? {
        return URL(string: "\(baseRosterURL)/roster/\(teamId)/current")
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
    
    
}
