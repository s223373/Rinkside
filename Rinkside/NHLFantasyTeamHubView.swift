//
//  NHLFantasyTeamHubView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/19/25.
//
import SwiftUI

struct NHLFantasyTeamHubView: View {
    @ObservedObject private var fantasyTeam: NHLFantasyTeam
    
    private var totalFantasyPoints: Int {
        fantasyTeam.getPlayers().reduce(0) { sum, player in
            sum + (player.featuredStats?.regularSeason?.subSeason.points ?? 0)
        }
    }
    
    
    public init(fantasyTeam: NHLFantasyTeam) {
        self.fantasyTeam = fantasyTeam
    }
    
    var body: some View {
        VStack {
            Text(fantasyTeam.getName())
                    .font(.largeTitle)
                    .padding(.top)

            Text("Total Points: \(totalFantasyPoints)")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(10)
                .background(Color.green)
                .cornerRadius(8)
            
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
            
            Text("Current Roster:")
                            .font(.headline)
                            .padding(.top)
            
            ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(fantasyTeam.getPlayers(), id: \.playerId) { player in
                                    PlayerFantasyRow(player: player, description: playerShortDescriptionFantasy(from: player))
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.bottom)
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
            Spacer()
            Text("\(player.featuredStats?.regularSeason?.subSeason.points ?? 0)")
                .font(.headline)
                 
        }
        .padding(.vertical, 5)
    }
}

func playerShortDescriptionFantasy(from player: NHLPlayer) -> String {
    return "#\(player.sweaterNumber) | \(calculateAge(from: player.birthDate ?? "2000-01-01") ?? 0) yo | \(player.position) | \(player.weightInPounds) lbs | \(getHeight(from: player.heightInInches)) in"
    
}
