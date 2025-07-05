//
//  NHLFantasyTeamLeague.swift
//  Rinkside
//
//  Created by Nik Bar on 6/26/25.
//
import Foundation

class NHLFantasyTeamLeague: Identifiable, Encodable, Decodable, Equatable, ObservableObject {
    static func == (lhs: NHLFantasyTeamLeague, rhs: NHLFantasyTeamLeague) -> Bool {
        lhs.teams == rhs.teams && lhs.userTeam == rhs.userTeam
    }
    
    var id = UUID()
    
    var teams: [NHLFantasyTeam] = []
    var leagueSize: Int
    var userTeam: NHLFantasyTeam
    
    var firstTeam: NHLFantasyTeam? {
            teams.first
        }

    init(userTeamName: String, leagueSize: Int) {
        self.userTeam = NHLFantasyTeam(name: userTeamName)
        self.teams.append(userTeam)
        self.leagueSize = leagueSize
    }

    
}
