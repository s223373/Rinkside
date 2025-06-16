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
    @Published private var players: [NHLPlayer]  = []
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
    
    public func addPlayer(_ player: NHLPlayerSkaterStats) {
        let player = convertNHLPlayer(playerId: player.playerId)!
        players.append(player)
    }
    
    public func convertNHLPlayer(playerId: Int) -> NHLPlayer? {
        draftedPlayerIds.insert(playerId)
        
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
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            players = try container.decode([NHLPlayer].self, forKey: .players)
            completedDraft = try container.decode(Bool.self, forKey: .completedDraft)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(id, forKey: .id)
            try container.encode(name, forKey: .name)
            try container.encode(players, forKey: .players)
            try container.encode(completedDraft, forKey: .completedDraft)
        }
    
    func clearPlayers() {
        players.removeAll()
    }
}
