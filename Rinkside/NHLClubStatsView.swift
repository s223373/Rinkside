//
//  NHLClubStatsView.swift
//  Rinkside
//
//  Created by Nik Bar on 4/9/25.
//
import SwiftUI

struct NHLClubStatsView: View {
    @State private var clubStats: NHLClubStats?
    @State private var selectedSkaterCategory = "Points"
    @State private var selectedGoalieCategory = "Wins"
    @State private var isLoading = true
    @State private var seasonId: String = "20242025"
    
    private let teamId: String
    
    private let skaterCategories = ["Points", "Goals", "Assists"]
    private let goalieCategories = ["Goals Against Average", "Save Percentage", "Wins"]
    
    // Available seasons - same as NHLRosterView
    private let availableSeasons = [
        "20242025", "20232024", "20222023", "20212022", "20202021"
    ]
    
    public init(teamId: String, seasonId: String = "20242025") {
        self.teamId = teamId
        self._seasonId = State(initialValue: seasonId)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGray6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.blue)
                    Text("Loading Team Stats...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else if let stats = clubStats {
                ScrollView {
                    VStack(spacing: 24) {
                        // Skaters Section
                        VStack(spacing: 16) {
                            SectionHeader(title: "Skaters", icon: "figure.hockey")
                            
                            // Skater category picker
                            CustomSegmentedPicker(
                                selection: $selectedSkaterCategory,
                                options: skaterCategories
                            )
                            
                            // Top skaters grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 1), spacing: 12) {
                                ForEach(Array(sortedSkaters(stats.skaters).prefix(10).enumerated()), id: \.offset) { index, skater in
                                    NavigationLink(destination: NHLPlayerView(playerId: skater.playerId)) {
                                        SkaterStatsCard(
                                            skater: skater,
                                            rank: index + 1,
                                            category: selectedSkaterCategory
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Goalies Section
                        VStack(spacing: 16) {
                            SectionHeader(title: "Goalies", icon: "shield.fill")
                            
                            // Goalie category picker
                            CustomSegmentedPicker(
                                selection: $selectedGoalieCategory,
                                options: goalieCategories
                            )
                            
                            // Goalies grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 1), spacing: 12) {
                                ForEach(Array(sortedGoalies(stats.goalies).enumerated()), id: \.offset) { index, goalie in
                                    NavigationLink(destination: NHLPlayerView(playerId: goalie.playerId)) {
                                        GoalieStatsCard(
                                            goalie: goalie,
                                            rank: index + 1,
                                            category: selectedGoalieCategory
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationTitle("Team Stats")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            seasonSelectionMenu
        }
        .onAppear {
            if clubStats == nil {
                decodeRegularSeasonTeamStats()
            }
        }
    }
    
    // MARK: - Season Selection Menu
    private var seasonSelectionMenu: some View {
        Menu {
            ForEach(availableSeasons, id: \.self) { season in
                Button(action: {
                    seasonId = season
                    isLoading = true
                    clubStats = nil // Clear existing stats
                    decodeRegularSeasonTeamStats()
                }) {
                    HStack {
                        Text("\(formattedSeason(season))")
                        if season == seasonId {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "calendar")
                Text(formattedSeason(seasonId))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(20)
        }
    }
    
    func sortedSkaters(_ skaters: [NHLClubSkaterStats]) -> [NHLClubSkaterStats] {
        switch selectedSkaterCategory {
        case "Goals":
            return skaters.sorted { ($0.goals ?? 0) > ($1.goals ?? 0) }
        case "Assists":
            return skaters.sorted { ($0.assists ?? 0) > ($1.assists ?? 0) }
        default:
            return skaters.sorted { ($0.points ?? 0) > ($1.points ?? 0) }
        }
    }
    
    func sortedGoalies(_ goalies: [NHLClubGoalieStats]) -> [NHLClubGoalieStats] {
        switch selectedGoalieCategory {
        case "Save Percentage":
            return goalies.sorted { ($0.savePercentage ?? 0) > ($1.savePercentage ?? 0) }
        case "Goals Against Average":
            return goalies.sorted { ($0.goalsAgainstAverage ?? 99) < ($1.goalsAgainstAverage ?? 99) }
        default:
            return goalies.sorted { ($0.wins ?? 0) > ($1.wins ?? 0) }
        }
    }

    func statText(for skater: NHLClubSkaterStats) -> String {
        switch selectedSkaterCategory {
        case "Goals": return "Goals: \(skater.goals ?? 0), Games Played: \(skater.gamesPlayed ?? 0)"
        case "Assists": return "Assists: \(skater.assists ?? 0), Games Played: \(skater.gamesPlayed ?? 0)"
        default: return "Points: \(skater.points ?? 0), Games Played: \(skater.gamesPlayed ?? 0)"
        }
    }

    func statText(for goalie: NHLClubGoalieStats) -> String {
        switch selectedGoalieCategory {
        case "Goals Against Average": return "GAA: \(String(format: "%.2f", goalie.goalsAgainstAverage ?? 0)), Games Played: \(goalie.gamesPlayed ?? 0)"
        case "Save Percentage": return "SV%: \(String(format: "%.3f", goalie.savePercentage ?? 0)), Games Played: \(goalie.gamesPlayed ?? 0)"
        default: return "Wins: \(goalie.wins ?? 0), Games Played: \(goalie.gamesPlayed ?? 0)"
        }
    }
    
    // MARK: - Helper Functions
    func formattedSeason(_ seasonId: String) -> String {
        let start = seasonId.prefix(4)
        let end = seasonId.suffix(4)
        return "\(start)-\(end)"
    }

    func decodeRegularSeasonTeamStats() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let url = NHLResource.regularSeasonClubStatsURL(for: teamId, with: seasonId) else {
            print("Invalid URL")
            DispatchQueue.main.async {
                self.isLoading = false
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching stats: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }

                guard let data = data else {
                    print("No data received")
                    self.isLoading = false
                    return
                }

                do {
                    let result = try decoder.decode(NHLClubStats.self, from: data)
                    self.clubStats = result
                    self.isLoading = false
                } catch {
                    print("Failed to decode: \(error)")
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

struct CustomSegmentedPicker: View {
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selection = option
                    }
                }) {
                    Text(option)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(selection == option ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Rectangle()
                                .fill(selection == option ? Color.blue : Color.clear)
                        )
                }
            }
        }
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

struct SkaterStatsCard: View {
    let skater: NHLClubSkaterStats
    let rank: Int
    let category: String
    
    var primaryStat: Int {
        switch category {
        case "Goals": return skater.goals ?? 0
        case "Assists": return skater.assists ?? 0
        default: return skater.points ?? 0
        }
    }
    
    var statLabel: String {
        switch category {
        case "Goals": return "G"
        case "Assists": return "A"
        default: return "PTS"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 32, height: 32)
                
                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Player headshot
            AsyncImage(url: URL(string: skater.headshot)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 2)
                    )
            } placeholder: {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    )
            }
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(skater.firstName) \(skater.lastName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Text("GP: \(skater.gamesPlayed ?? 0)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if category != "Points" {
                        Text("PTS: \(skater.points ?? 0)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Primary stat
            VStack(spacing: 2) {
                Text("\(primaryStat)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.blue)
                
                Text(statLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color.orange
        case 2: return Color.gray
        case 3: return Color.brown
        default: return Color.blue
        }
    }
}

struct GoalieStatsCard: View {
    let goalie: NHLClubGoalieStats
    let rank: Int
    let category: String
    
    var primaryStat: String {
        switch category {
        case "Goals Against Average": return String(format: "%.2f", goalie.goalsAgainstAverage ?? 0)
        case "Save Percentage": return String(format: "%.3f", goalie.savePercentage ?? 0)
        default: return "\(goalie.wins ?? 0)"
        }
    }
    
    var statLabel: String {
        switch category {
        case "Goals Against Average": return "GAA"
        case "Save Percentage": return "SV%"
        default: return "W"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 32, height: 32)
                
                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Player headshot
            AsyncImage(url: URL(string: goalie.headshot)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 2)
                    )
            } placeholder: {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "shield.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    )
            }
            
            // Player info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(goalie.firstName) \(goalie.lastName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Text("GP: \(goalie.gamesPlayed ?? 0)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("W: \(goalie.wins ?? 0)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("L: \(goalie.losses ?? 0)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Primary stat
            VStack(spacing: 2) {
                Text(primaryStat)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.green)
                
                Text(statLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color.orange
        case 2: return Color.gray
        case 3: return Color.brown
        default: return Color.green
        }
    }
}
