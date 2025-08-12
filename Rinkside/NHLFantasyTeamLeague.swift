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
    
    @Published var teams: [NHLFantasyTeam] = []
    var leagueSize: Int
    var userTeam: NHLFantasyTeam
    
    var firstTeam: NHLFantasyTeam? {
        teams.first
    }
    
    // Default team names for CPU teams
    private let defaultTeamNames = [
        "Ice Breakers", "Power Player", "Hat Trick Heroes", "Frozen Assets",
        "Penalty Killers", "Gold Diggers", "Slapshot Stars", "Ice Cold",
        "Puck Dynasty", "Blue Line Bombers", "Overtime Warriors", "Stick Handlers",
        "Net Crashers", "Face-Off Kings", "Hockey Legends", "Ice Storm",
        "Puck Stoppers", "Goal Line Guards", "Assist Masters", "Championship Chasers"
    ]

    init(userTeamName: String, leagueSize: Int) {
        self.userTeam = NHLFantasyTeam(name: userTeamName)
        self.leagueSize = leagueSize
        self.teams.append(userTeam)
        
        
        // Generate CPU teams
        generateCPUTeams()
    }
    
    private func generateCPUTeams() {
        let cpuTeamCount = leagueSize - 1 // Subtract 1 for user team
        let shuffledNames = defaultTeamNames.shuffled()
        
        for i in 0..<min(cpuTeamCount, shuffledNames.count) {
            let cpuTeam = NHLFantasyTeam(name: shuffledNames[i])
            teams.append(cpuTeam)
        }
    }
    
    // Get league standings sorted by total fantasy points
    func getLeagueStandings() -> [NHLFantasyTeam] {
        return teams.sorted { team1, team2 in
            let points1 = team1.getTotalFantasyPoints()
            let points2 = team2.getTotalFantasyPoints()
            return points1 > points2
        }
    }
    
    // Get user's rank in the league
    func getUserRank() -> Int {
        let standings = getLeagueStandings()
        return (standings.firstIndex(of: userTeam) ?? 0) + 1
    }
    
    // Check if all teams have completed their drafts
    func isLeagueDraftComplete() -> Bool {
        return teams.allSatisfy { $0.getCompletedDraft() }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case teams
        case leagueSize
        case userTeam
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        teams = try container.decode([NHLFantasyTeam].self, forKey: .teams)
        leagueSize = try container.decode(Int.self, forKey: .leagueSize)
        userTeam = try container.decode(NHLFantasyTeam.self, forKey: .userTeam)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(teams, forKey: .teams)
        try container.encode(leagueSize, forKey: .leagueSize)
        try container.encode(userTeam, forKey: .userTeam)
    }
}
