//
//  NHLFantasyTeamHubView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/19/25.
//
import SwiftUI

struct NHLFantasyTeamHubView: View {
    @ObservedObject private var fantasyTeam: NHLFantasyTeam
    
    
    public init(fantasyTeam: NHLFantasyTeam) {
        self.fantasyTeam = fantasyTeam
    }
    
    var body: some View {
        VStack {
            Text(fantasyTeam.getName())
            if (!fantasyTeam.getCompletedDraft()) {
                NavigationLink(destination: NHLFantasyDraftView(fantasyTeam: fantasyTeam)) {
                    HStack {
                        Text("Complete Draft")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
                
            }
            
            Section(header: Text("Current Roster: ").font(.headline)) {
                ForEach(fantasyTeam.getPlayers(), id: \.playerId) { player in
                    PlayerFantasyRow(player: player, description: playerShortDescriptionFantasy(from: player))
                }
            }
            
        }
    }
}

struct PlayerFantasyRow: View {
    let player: NHLPlayer
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: player.headshot)) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }
            VStack(alignment: .leading) {
                Text("\(player.firstName.def) \(player.lastName.def)")
                    .font(.body)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 5)
    }
}

func playerShortDescriptionFantasy(from player: NHLPlayer) -> String {
    return "#\(player.sweaterNumber) | \(calculateAge(from: player.birthDate ?? "2000-01-01") ?? 0) yo | \(player.position) | \(player.weightInPounds) lbs | \(getHeight(from: player.heightInInches)) in"
    
}
