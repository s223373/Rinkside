//
//  NHLFantasyListView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//
import SwiftUI

struct NHLFantasyListView: View {
    private var fantasyTeams: [NHLFantasyTeam]
    
    public init(fantasyTeams: [NHLFantasyTeam]) {
        self.fantasyTeams = fantasyTeams
    }
    
    var body: some View {
        Text("NHLFantasyListView")
    }
}
