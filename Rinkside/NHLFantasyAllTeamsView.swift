//
//  NHLFantasyAllTeamsView.swift
//  Rinkside
//
//  Created by Nik Bar on 6/26/25.
//
import SwiftUI

struct NHLFantasyAllTeamsView: View {
    @ObservedObject private var fantasyLeague: NHLFantasyTeamLeague
    @State private var selectedTeam: NHLFantasyTeam?
    @State private var showingTeamDetail = false
    
    init(fantasyLeague: NHLFantasyTeamLeague) {
        self.fantasyLeague = fantasyLeague
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // Teams Grid
                    teamsGridSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("All Teams")
            .navigationBarTitleDisplayMode(.large)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .sheet(isPresented: $showingTeamDetail) {
            if let team = selectedTeam {
                TeamDetailView(team: team, fantasyLeague: fantasyLeague)
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("League Teams")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(fantasyLeague.leagueSize)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Teams")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.gradient)
                        .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                )
                
                VStack(spacing: 4) {
                    Text("\(getTotalPlayers())")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Total Players")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.gradient)
                        .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                )
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Teams Grid Section
    
    private var teamsGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(fantasyLeague.teams, id: \.id) { team in
                TeamCard(
                    team: team,
                    isUserTeam: team.id == fantasyLeague.userTeam.id,
                    rank: getRankForTeam(team)
                ) {
                    selectedTeam = team
                    showingTeamDetail = true
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getTotalPlayers() -> Int {
        return fantasyLeague.teams.reduce(0) { sum, team in
            sum + team.getPlayers().count
        }
    }
    
    private func getRankForTeam(_ team: NHLFantasyTeam) -> Int {
        let standings = fantasyLeague.getLeagueStandings()
        return (standings.firstIndex(of: team) ?? 0) + 1
    }
}

// MARK: - Team Card

struct TeamCard: View {
    let team: NHLFantasyTeam
    let isUserTeam: Bool
    let rank: Int
    let onTap: () -> Void
    
    private var rankColor: Color {
        switch rank {
        case 1: return .gold
        case 2: return .gray
        case 3: return .brown
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Rank and Team Name
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(rankColor.gradient)
                            .frame(width: 32, height: 32)
                            .shadow(color: rankColor.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Text("#\(rank)")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    
                    Text(team.getName())
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    if isUserTeam {
                        Text("(Your Team)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                    }
                }
                
                Divider()
                
                // Team Stats
                VStack(spacing: 8) {
                    HStack {
                        Text("Points:")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(team.getTotalFantasyPoints())")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    let composition = team.getTeamComposition()
                    HStack {
                        Text("Roster:")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(composition.forwards + composition.defensemen + composition.goalies)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("F/D/G:")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(composition.forwards)/\(composition.defensemen)/\(composition.goalies)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isUserTeam ? Color.blue.opacity(0.1) : Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isUserTeam ? Color.blue.opacity(0.3) : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Team Detail View

struct TeamDetailView: View {
    let team: NHLFantasyTeam
    let fantasyLeague: NHLFantasyTeamLeague
    @Environment(\.dismiss) private var dismiss
    
    private var isUserTeam: Bool {
        team.id == fantasyLeague.userTeam.id
    }
    
    private var teamRank: Int {
        let standings = fantasyLeague.getLeagueStandings()
        return (standings.firstIndex(of: team) ?? 0) + 1
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    teamHeaderSection
                    
                    // Team Stats Section
                    teamStatsSection
                    
                    // Players Section
                    playersSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle(team.getName())
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // MARK: - Team Header Section
    
    private var teamHeaderSection: some View {
        VStack(spacing: 16) {
            if isUserTeam {
                Text("Your Team")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("#\(teamRank)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("League Rank")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(getRankColor().gradient)
                        .shadow(color: getRankColor().opacity(0.3), radius: 8, x: 0, y: 4)
                )
                
                VStack(spacing: 4) {
                    Text("\(team.getTotalFantasyPoints())")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Total Points")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.green.gradient)
                        .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
        }
    }
    
    // MARK: - Team Stats Section
    
    private var teamStatsSection: some View {
        VStack(spacing: 16) {
            Text("Team Composition")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let composition = team.getTeamComposition()
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "Forwards",
                    value: "\(composition.forwards)",
                    subtitle: "players",
                    color: .red
                )
                
                StatCard(
                    title: "Defensemen",
                    value: "\(composition.defensemen)",
                    subtitle: "players",
                    color: .blue
                )
                
                StatCard(
                    title: "Goalies",
                    value: "\(composition.goalies)",
                    subtitle: "players",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Players Section
    
    private var playersSection: some View {
        VStack(spacing: 16) {
            Text("Roster (\(team.getPlayers().count))")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if team.getPlayers().isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    Text("No players drafted yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(team.getPlayers().sorted { $0.featuredStats?.regularSeason?.subSeason.points ?? 0 > $1.featuredStats?.regularSeason?.subSeason.points ?? 0 }, id: \.playerId) { player in
                        PlayerDetailRow(player: player)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getRankColor() -> Color {
        switch teamRank {
        case 1: return .gold
        case 2: return .gray
        case 3: return .brown
        default: return .blue
        }
    }
}

// MARK: - Player Detail Row

struct PlayerDetailRow: View {
    let player: NHLPlayer
    
    var body: some View {
        HStack(spacing: 16) {
            // Player Image
            AsyncImage(url: URL(string: player.headshot)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    )
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(player.firstName.def) \(player.lastName.def)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("\(player.position) • #\(player.sweaterNumber ?? 0)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Points
            Text("\(player.featuredStats?.regularSeason?.subSeason.points ?? 0)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.green)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Color Extensions

extension Color {
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
}
