//
//  NHLFantasyTeam.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//
import Foundation

class NHLFantasyTeam: Identifiable, Codable, Equatable {
    static func == (lhs: NHLFantasyTeam, rhs: NHLFantasyTeam) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String
    private var name: String
    private var players: [NHLPlayer]  = []
    private var completedDraft: Bool = false
    
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
}
