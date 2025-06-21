//
//  NHLFantasyTeamHubView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/19/25.
//
import SwiftUI

struct NHLFantasyTeamHubView: View {
    @ObservedObject private var fantasyTeam: NHLFantasyTeam

    
    @State private var activeForwards: [NHLPlayer] = []
    @State private var activeDefensemen: [NHLPlayer] = []
    @State private var activeGoalies: [NHLPlayer] = []

   

    private var allForwards: [NHLPlayer] {
        fantasyTeam.getPlayers().filter { ["C", "L", "R"].contains($0.position) }
    }

    private var allDefensemen: [NHLPlayer] {
        fantasyTeam.getPlayers().filter { $0.position == "D" }
    }

    private var allGoalies: [NHLPlayer] {
        fantasyTeam.getPlayers().filter { $0.position == "G" }
    }

    private var benchPlayers: [NHLPlayer] {
        let activeIds = Set(activeForwards.map(\.playerId) +
                            activeDefensemen.map(\.playerId) +
                            activeGoalies.map(\.playerId))
        return fantasyTeam.getPlayers().filter { !activeIds.contains($0.playerId) }
    }

    private var totalFantasyPoints: Int {
        fantasyTeam.getPlayers().reduce(0) { sum, player in
            sum + (player.featuredStats?.regularSeason?.subSeason.points ?? 0)
        }
    }

    public init(fantasyTeam: NHLFantasyTeam) {
        self.fantasyTeam = fantasyTeam
    }

    enum FantasyPositionGroup {
        case forward, defense, goalie
    }

    // MARK: - Body

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

            if !fantasyTeam.getCompletedDraft() {
                NavigationLink(destination: NHLFantasyDraftView(fantasyTeam: fantasyTeam)) {
                    HStack {
                        Text("Complete Draft")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
                }
            }

            Text("Active Lineup")
                .font(.headline)
                .padding(.top)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // FORWARDS
                    VStack(alignment: .leading) {
                        Text("Forwards")
                            .font(.title3)
                            .bold()
                        ForEach(activeForwards, id: \.playerId) { player in
                            PlayerFantasyRow(player: player, description: playerShortDescriptionFantasy(from: player))
                        }
                    }
                    .onDrop(of: [.utf8PlainText], isTargeted: nil) { providers in
                        handleDrop(providers: providers, for: .forward)
                    }

                    // DEFENSEMEN
                    VStack(alignment: .leading) {
                        Text("Defensemen")
                            .font(.title3)
                            .bold()
                        ForEach(activeDefensemen, id: \.playerId) { player in
                            PlayerFantasyRow(player: player, description: playerShortDescriptionFantasy(from: player))
                        }
                    }
                    .onDrop(of: [.utf8PlainText], isTargeted: nil) { providers in
                        handleDrop(providers: providers, for: .defense)
                    }

                    // GOALIES
                    VStack(alignment: .leading) {
                        Text("Goalies")
                            .font(.title3)
                            .bold()
                        ForEach(activeGoalies, id: \.playerId) { player in
                            PlayerFantasyRow(player: player, description: playerShortDescriptionFantasy(from: player))
                        }
                    }
                    .onDrop(of: [.utf8PlainText], isTargeted: nil) { providers in
                        handleDrop(providers: providers, for: .goalie)
                    }

                    // BENCH
                    VStack(alignment: .leading) {
                        Text("Bench")
                            .font(.title3)
                            .bold()
                        ForEach(benchPlayers, id: \.playerId) { player in
                            PlayerFantasyRow(player: player, description: playerShortDescriptionFantasy(from: player))
                                .onDrag {
                                    NSItemProvider(object: String(player.playerId) as NSString)
                                }
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .onAppear {
            // Prefill active lineup once
            if activeForwards.isEmpty {
                activeForwards = Array(allForwards.prefix(12))
            }
            if activeDefensemen.isEmpty {
                activeDefensemen = Array(allDefensemen.prefix(6))
            }
            if activeGoalies.isEmpty {
                activeGoalies = Array(allGoalies.prefix(2))
            }
        }
    }

    // MARK: - Drop Handler

    private func handleDrop(providers: [NSItemProvider], for group: FantasyPositionGroup) -> Bool {
        for provider in providers {
            provider.loadObject(ofClass: String.self) { string, _ in
                guard let playerId = string.flatMap({ Int($0) }),
                      let player = fantasyTeam.getPlayers().first(where: { $0.playerId == playerId }) else { return }

                DispatchQueue.main.async {
                    switch group {
                    case .forward:
                        guard ["C", "L", "R"].contains(player.position) else { return }
                        if !activeForwards.contains(where: { $0.playerId == player.playerId }) {
                            if activeForwards.count >= 12 {
                                activeForwards.removeFirst()
                            }
                            activeForwards.append(player)
                        }
                    case .defense:
                        guard player.position == "D" else { return }
                        if !activeDefensemen.contains(where: { $0.playerId == player.playerId }) {
                            if activeDefensemen.count >= 6 {
                                activeDefensemen.removeFirst()
                            }
                            activeDefensemen.append(player)
                        }
                    case .goalie:
                        guard player.position == "G" else { return }
                        if !activeGoalies.contains(where: { $0.playerId == player.playerId }) {
                            if activeGoalies.count >= 2 {
                                activeGoalies.removeFirst()
                            }
                            activeGoalies.append(player)
                        }
                    }
                }
            }
        }
        return true
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
