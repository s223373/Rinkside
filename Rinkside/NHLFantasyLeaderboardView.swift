//
//  NHLFantasyLeaderboardView.swift
//  Rinkside
//
//  Created by Nik Bar on 6/26/25.
//
import SwiftUI

struct NHLFantasyLeaderboardView: View {
    @ObservedObject private var fantasyLeague: NHLFantasyTeamLeague
    
    init(fantasyLeague: NHLFantasyTeamLeague) {
        self.fantasyLeague = fantasyLeague
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    headerSection
                    
                    // League Stats Overview
                    leagueStatsSection
                    
                    // Leaderboard
                    leaderboardSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .navigationTitle("League Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("Fantasy League Standings")
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
                    Text("#\(fantasyLeague.getUserRank())")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Your Rank")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(getRankColor().gradient)
                        .shadow(color: getRankColor().opacity(0.3), radius: 6, x: 0, y: 3)
                )
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - League Stats Section
    
    private var leagueStatsSection: some View {
        VStack(spacing: 16) {
            Text("League Overview")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let standings = fantasyLeague.getLeagueStandings()
            let topTeam = standings.first
            let averagePoints = Int(standings.map { $0.getTotalFantasyPoints() }.reduce(0, +) / max(standings.count, 1))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "League Leader",
                    value: topTeam?.getName() ?? "N/A",
                    subtitle: "\(topTeam?.getTotalFantasyPoints() ?? 0) pts",
                    color: .gold
                )
                
                StatCard(
                    title: "Average Points",
                    value: "\(averagePoints)",
                    subtitle: "per team",
                    color: .purple
                )
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Leaderboard Section
    
    private var leaderboardSection: some View {
        VStack(spacing: 16) {
            Text("Team Rankings")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(fantasyLeague.getLeagueStandings().enumerated()), id: \.element.id) { index, team in
                    TeamRankRow(
                        team: team,
                        rank: index + 1,
                        isUserTeam: team.id == fantasyLeague.userTeam.id
                    )
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Helper Methods
    
    private func getRankColor() -> Color {
        let rank = fantasyLeague.getUserRank()
        let totalTeams = fantasyLeague.leagueSize
        let percentage = Double(rank) / Double(totalTeams)
        
        if percentage <= 0.25 {
            return .green
        } else if percentage <= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.gradient)
                .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
        )
    }
}

struct TeamRankRow: View {
    let team: NHLFantasyTeam
    let rank: Int
    let isUserTeam: Bool
    
    private var rankColor: Color {
        switch rank {
        case 1: return .gold
        case 2: return .gray
        case 3: return .brown
        default: return .blue
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "number"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rankColor.gradient)
                    .frame(width: 40, height: 40)
                    .shadow(color: rankColor.opacity(0.3), radius: 4, x: 0, y: 2)
                
                if rank <= 3 {
                    Image(systemName: rankIcon)
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                } else {
                    Text("\(rank)")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            
            // Team Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(team.getName())
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    if isUserTeam {
                        Text("(You)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)
                    }
                }
                
                let composition = team.getTeamComposition()
                Text("\(composition.forwards)F • \(composition.defensemen)D • \(composition.goalies)G")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Points
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(team.getTotalFantasyPoints())")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("points")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isUserTeam ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isUserTeam ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - Color Extensions


