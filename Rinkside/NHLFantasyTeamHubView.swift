//
//  NHLFantasyTeamHubView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/19/25.
//
import SwiftUI

struct NHLFantasyTeamHubView: View {
    @ObservedObject private var fantasyTeam: NHLFantasyTeam
    @ObservedObject private var fantasyLeague: NHLFantasyTeamLeague

    @State private var activeForwards: [NHLPlayer] = []
    @State private var activeDefensemen: [NHLPlayer] = []
    @State private var activeGoalies: [NHLPlayer] = []
    
    @State private var hoveredForwardID: Int? = nil
    @State private var hoveredDefenseID: Int? = nil
    @State private var hoveredGoalieID: Int? = nil

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

    public init(fantasyTeam: NHLFantasyTeam, fantasyLeague: NHLFantasyTeamLeague) {
        self.fantasyTeam = fantasyTeam
        self.fantasyLeague = fantasyLeague
    }

    enum FantasyPositionGroup {
        case forward, defense, goalie
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Draft Button Section
                if !fantasyTeam.getCompletedDraft() {
                    draftButtonSection
                }
                
                // Active Lineup Section
                activeLineupSection
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            setupInitialLineup()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text(fantasyTeam.getName())
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Stats Card
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(totalFantasyPoints)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Total Points")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                
                VStack(spacing: 4) {
                    Text("\(fantasyTeam.getPlayers().count)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Players")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - Draft Button Section
    
    private var draftButtonSection: some View {
        NavigationLink(destination: NHLFantasyDraftView(fantasyTeam: fantasyTeam, fantasyLeague: fantasyLeague)) {
            HStack(spacing: 12) {
                Image(systemName: "person.3.fill")
                    .font(.title2)
                Text("Complete Draft")
                    .font(.title2)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.orange.opacity(0.4), radius: 8, x: 0, y: 4)
            )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - Active Lineup Section
    
    private var activeLineupSection: some View {
        VStack(spacing: 24) {
            Text("Active Lineup")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            
            VStack(spacing: 24) {
                // Forwards Section
                positionSection(
                    title: "Forwards",
                    players: activeForwards,
                    icon: "figure.hockey",
                    color: Color.red,
                    hoveredID: hoveredForwardID,
                    positionGroup: .forward
                )
                
                // Defensemen Section
                positionSection(
                    title: "Defensemen",
                    players: activeDefensemen,
                    icon: "shield.fill",
                    color: Color.blue,
                    hoveredID: hoveredDefenseID,
                    positionGroup: .defense
                )
                
                // Goalies Section
                positionSection(
                    title: "Goalies",
                    players: activeGoalies,
                    icon: "target",
                    color: Color.purple,
                    hoveredID: hoveredGoalieID,
                    positionGroup: .goalie
                )
                
                // Bench Section
                benchSection
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Position Section
    
    private func positionSection(
        title: String,
        players: [NHLPlayer],
        icon: String,
        color: Color,
        hoveredID: Int?,
        positionGroup: FantasyPositionGroup
    ) -> some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(players.count)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(color))
            }
            
            LazyVStack(spacing: 12) {
                ForEach(players, id: \.playerId) { player in
                    PlayerFantasyRow(player: player, description: playerShortDescriptionFantasy(from: player))
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(hoveredID == player.playerId ? color.opacity(0.2) : Color.clear)
                        )
                        .onDrop(of: [.utf8PlainText], isTargeted: nil) { providers in
                            setHoveredID(player.playerId, for: positionGroup)
                            return handleDrop(providers: providers, replacing: player, in: positionGroup)
                        }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Bench Section
    
    private var benchSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text("Bench")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Spacer()
                Text("\(benchPlayers.count)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.orange))
            }
            
            LazyVStack(spacing: 12) {
                ForEach(benchPlayers, id: \.playerId) { player in
                    PlayerFantasyRow(player: player, description: playerShortDescriptionFantasy(from: player))
                        .opacity(0.8)
                        .onDrag {
                            NSItemProvider(object: String(player.playerId) as NSString)
                        }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Helper Methods
    
    private func setupInitialLineup() {
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
    
    private func setHoveredID(_ id: Int, for group: FantasyPositionGroup) {
        switch group {
        case .forward:
            hoveredForwardID = id
        case .defense:
            hoveredDefenseID = id
        case .goalie:
            hoveredGoalieID = id
        }
    }

    // MARK: - Drop Handler

    private func handleDrop(providers: [NSItemProvider], replacing target: NHLPlayer, in group: FantasyPositionGroup) -> Bool {
        for provider in providers {
            provider.loadObject(ofClass: String.self) { string, _ in
                guard let playerId = string.flatMap({ Int($0) }),
                      let newPlayer = fantasyTeam.getPlayers().first(where: { $0.playerId == playerId }) else { return }

                DispatchQueue.main.async {
                    switch group {
                    case .forward:
                        guard ["C", "L", "R"].contains(newPlayer.position),
                              let index = activeForwards.firstIndex(where: { $0.playerId == target.playerId }) else { return }
                        activeForwards[index] = newPlayer

                    case .defense:
                        guard newPlayer.position == "D",
                              let index = activeDefensemen.firstIndex(where: { $0.playerId == target.playerId }) else { return }
                        activeDefensemen[index] = newPlayer

                    case .goalie:
                        guard newPlayer.position == "G",
                              let index = activeGoalies.firstIndex(where: { $0.playerId == target.playerId }) else { return }
                        activeGoalies[index] = newPlayer
                    }
                }
            }
        }
        return true
    }
}

// MARK: - Player Row Component

struct PlayerFantasyRow: View {
    let player: NHLPlayer
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Player Image
            AsyncImage(url: URL(string: player.headshot)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
            } placeholder: {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                    )
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(player.firstName.def) \(player.lastName.def)")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Points Badge
            VStack(spacing: 2) {
                Text("\(player.featuredStats?.regularSeason?.subSeason.points ?? 0)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("PTS")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(width: 50, height: 50)
            .background(
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

func playerShortDescriptionFantasy(from player: NHLPlayer) -> String {
    return "#\(player.sweaterNumber ?? -1) • \(calculateAge(from: player.birthDate ?? "2000-01-01") ?? 0) yo • \(player.position) • \(player.weightInPounds) lbs • \(getHeight(from: player.heightInInches)) in"
}
