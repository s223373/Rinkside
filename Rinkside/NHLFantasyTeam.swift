//
//  NHLFantasyTeam.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//

class NHLFantasyTeam {
    private var id: Int
    private var name: String
    private var players: [NHLPlayer]  = []
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
