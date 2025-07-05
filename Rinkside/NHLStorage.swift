//
//  NHLStorage.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//
import Foundation

class FantasyTeamStorage {
    private static let key = "fantasyTeams"

    static func save(_ teams: [NHLFantasyTeamLeague]) {
        if let data = try? JSONEncoder().encode(teams) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> [NHLFantasyTeamLeague] {
        if let data = UserDefaults.standard.data(forKey: key),
           let teams = try? JSONDecoder().decode([NHLFantasyTeamLeague].self, from: data) {
            return teams
        }
        return []
    }
}
