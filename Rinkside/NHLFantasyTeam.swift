//
//  NHLFantasyTeam.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//
import Foundation

class NHLFantasyTeam: Identifiable, Codable, Equatable, ObservableObject {
    static func == (lhs: NHLFantasyTeam, rhs: NHLFantasyTeam) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String
    @Published private var name: String
    @Published private var players: [NHLPlayer] = []
    @Published private var completedDraft: Bool = false
    @Published private(set) var draftedPlayerIds: Set<Int> = []
    
    public var draftedPlayers: [NHLPlayer] {
        return players
    }
    
    init(name: String) {
        id = UUID().uuidString
        self.name = name
    }
    
    public func getName() -> String {
        return name
    }
    
    public func getPlayers() -> [NHLPlayer] {
        return players
    }
    
    public func getId() -> String {
        return id
    }
    
    public func getCompletedDraft() -> Bool {
        return completedDraft
    }
    
    public func setCompletedDraft(_ completedDraft: Bool) {
        self.completedDraft = completedDraft
    }
    
    // Calculate total fantasy points for the team
    public func getTotalFantasyPoints() -> Int {
        return players.reduce(0) { sum, player in
            sum + (player.featuredStats?.regularSeason?.subSeason.points ?? 0)
        }
    }
    
    // Get team composition stats
    public func getTeamComposition() -> (forwards: Int, defensemen: Int, goalies: Int) {
        let forwards = players.filter { ["C", "L", "R", "F"].contains($0.position) }.count
        let defensemen = players.filter { $0.position == "D" }.count
        let goalies = players.filter { $0.position == "G" }.count
        return (forwards, defensemen, goalies)
    }
    
    // Get top scorer on the team
    public func getTopScorer() -> NHLPlayer? {
        return players.max { player1, player2 in
            let points1 = player1.featuredStats?.regularSeason?.subSeason.points ?? 0
            let points2 = player2.featuredStats?.regularSeason?.subSeason.points ?? 0
            return points1 < points2
        }
    }
    
    public func addPlayer(_ player: NHLPlayerSkaterStats) {
        // Add the player ID to the drafted set first
        draftedPlayerIds.insert(player.playerId ?? -1)
        
        // Then convert and add the player
        let convertedPlayer = convertNHLPlayer(playerId: player.playerId ?? -1)!
        players.append(convertedPlayer)
    }

    public func convertNHLPlayer(playerId: Int) -> NHLPlayer? {
        var player: NHLPlayer?
        let decoder = JSONDecoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        guard let url = NHLResource.basePlayerLandingURL(for: playerId) else { return nil }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            defer { semaphore.signal() }
            guard let data = data else { return }
            do {
                player = try decoder.decode(NHLPlayer.self, from: data)
            } catch {
                print(error)
            }
        }.resume()
        
        semaphore.wait()
        return player
    }
    
    func hasDrafted(_ playerId: Int) -> Bool {
        draftedPlayerIds.contains(playerId)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case players
        case completedDraft
        case draftedPlayerIds
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        players = try container.decode([NHLPlayer].self, forKey: .players)
        completedDraft = try container.decode(Bool.self, forKey: .completedDraft)
        
        // Handle draftedPlayerIds if present, otherwise initialize empty
        draftedPlayerIds = try container.decodeIfPresent(Set<Int>.self, forKey: .draftedPlayerIds) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(players, forKey: .players)
        try container.encode(completedDraft, forKey: .completedDraft)
        try container.encode(draftedPlayerIds, forKey: .draftedPlayerIds)
    }
    
    func clearPlayers() {
        players.removeAll()
        draftedPlayerIds.removeAll()
    }
}
