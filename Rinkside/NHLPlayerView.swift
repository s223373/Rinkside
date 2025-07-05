//
//  NHLPlayerView.swift
//  Rinkside
//
//  Created by Nik Bar on 12/28/24.
//
//
//  NHLPlayerView.swift
//  Rinkside
//
//  Created by Nik Bar on 12/28/24.
//
import SwiftUI

struct NHLPlayerView: View {
    @State private var playerInfo: NHLPlayer?
    @State private var showingCompareSheet = false
    @State private var compareName = ""
    @State private var navigateToCompare = false
    @State private var secondPlayerId: Int?
    @State private var selectedStatsType: StatsType = .regular
    
    var playerRating: Int? {
        guard let player = playerInfo,
              let latestSeason = player.seasonTotals?
                .filter({ $0.gameTypeId == 2 })
                .sorted(by: { ($0.season ?? 0) > ($1.season ?? 0) })
                .first else {
            return nil
        }
        
        let raw = PlayerRatingEngine.calculateRawSkaterScore(for: latestSeason)
        return PlayerRatingEngine.scaleToRating(rawScore: raw, mean: 60, stdDev: 10)
    }

    private let playerId: Int
    
    init(playerId: Int) {
        self.playerId = playerId
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                NavigationLink(
                    destination: NHLPlayerCompareView(player1Id: playerId, player2Id: secondPlayerId ?? 0),
                    isActive: $navigateToCompare
                ) {
                    EmptyView()
                }
                .hidden()
                
                if let player = playerInfo {
                    VStack(spacing: 0) {
                        EnhancedPlayerHeaderView(player: player, rating: playerRating)
                        
                        VStack(spacing: 16) {
                            EnhancedPlayerDetailsView(player: player)
                            EnhancedPlayerStatsView(player: player, selectedStatsType: $selectedStatsType)
                        }
                        .padding(.horizontal, min(16, geometry.size.width * 0.05))
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                } else {
                    EnhancedLoadingView()
                        .onAppear {
                            decodePlayer(playerId: playerId)
                        }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCompareSheet = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 12))
                        Text("Compare")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
            }
        }
        .sheet(isPresented: $showingCompareSheet) {
            CompareStatsSheet(
                player1Id: playerId,
                compareName: $compareName
            ) { player2Id in
                self.secondPlayerId = player2Id
                self.navigateToCompare = true
            }
        }
    }
    
    func decodePlayer(playerId: Int) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let url = NHLResource.basePlayerLandingURL(for: playerId) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                do {
                    playerInfo = try decoder.decode(NHLPlayer.self, from: data)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}

enum StatsType: String, CaseIterable {
    case regular = "Regular Season"
    case playoffs = "Playoffs"
    case career = "Career"
}

struct EnhancedPlayerHeaderView: View {
    let player: NHLPlayer
    let rating: Int?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background hero image with gradient overlay - extended to cover entire view
                AsyncImage(url: URL(string: player.heroImage)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 420)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.black.opacity(0.8),
                                    Color.black.opacity(0.4),
                                    Color.black.opacity(0.8)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                } placeholder: {
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.3),
                                Color.purple.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: geometry.size.width, height: 420)
                }
                
                VStack(spacing: 16) {
                    Spacer()
                    
                    // Player photo with enhanced styling - centered in VStack
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: min(140, geometry.size.width * 0.35), height: min(140, geometry.size.width * 0.35))
                                .blur(radius: 15)
                            
                            AsyncImage(url: URL(string: player.headshot)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: min(120, geometry.size.width * 0.3), height: min(120, geometry.size.width * 0.3))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(LinearGradient(
                                                gradient: Gradient(colors: [.white, .blue.opacity(0.8)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ), lineWidth: 3)
                                    )
                                    .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 8)
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: min(120, geometry.size.width * 0.3), height: min(120, geometry.size.width * 0.3))
                                    .overlay(
                                        ProgressView()
                                            .tint(.white)
                                    )
                            }
                            
                            // Enhanced rating badge
                            if let rating = rating {
                                VStack(spacing: 2) {
                                    Text("\(rating)")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("OVR")
                                        .font(.system(size: 8, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(ratingColor(for: rating))
                                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                                )
                                .offset(x: min(50, geometry.size.width * 0.12), y: min(-50, -geometry.size.width * 0.12))
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Player name and info
                    VStack(spacing: 12) {
                        VStack(spacing: 6) {
                            Text("\(player.firstName.def) \(player.lastName.def)")
                                .font(.system(size: min(28, geometry.size.width * 0.07), weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            
                            Text(player.fullTeamName?.def ?? "Free Agent")
                                .font(.system(size: min(16, geometry.size.width * 0.04), weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: min(20, geometry.size.width * 0.05)) {
                            PlayerInfoBadge(
                                icon: "number",
                                title: "Number",
                                value: "#\(player.sweaterNumber ?? 0)",
                                isCompact: geometry.size.width < 400
                            )
                            
                            PlayerInfoBadge(
                                icon: "figure.hockey",
                                title: "Position",
                                value: player.position,
                                isCompact: geometry.size.width < 400
                            )
                            
                            PlayerInfoBadge(
                                icon: "calendar",
                                title: "Age",
                                value: "\(calculateAge(from: player.birthDate ?? "2001-01-01") ?? 0)",
                                isCompact: geometry.size.width < 400
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, min(20, geometry.size.width * 0.05))
            }
        }
        .frame(height: 420)
    }
    
    private func ratingColor(for rating: Int) -> LinearGradient {
        let colors: [Color]
        if rating >= 90 {
            colors = [.green, .mint]
        } else if rating >= 80 {
            colors = [.blue, .cyan]
        } else if rating >= 70 {
            colors = [.orange, .yellow]
        } else {
            colors = [.red, .pink]
        }
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct PlayerInfoBadge: View {
    let icon: String
    let title: String
    let value: String
    var isCompact: Bool = false
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: isCompact ? 12 : 14, weight: .semibold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: isCompact ? 8 : 9, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: isCompact ? 10 : 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, isCompact ? 8 : 10)
        .padding(.vertical, isCompact ? 6 : 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct EnhancedPlayerDetailsView: View {
    let player: NHLPlayer
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Player Profile")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                DetailCard(
                    icon: "calendar",
                    title: "Born",
                    value: formatDate(player.birthDate ?? "2001-01-01"),
                    gradient: [.blue, .purple]
                )
                
                DetailCard(
                    icon: "location",
                    title: "Birthplace",
                    value: "\(player.birthCity.def ?? "Unknown"), \(player.birthCountry)",
                    gradient: [.green, .mint]
                )
                
                HStack(spacing: 8) {
                    DetailCard(
                        icon: "ruler",
                        title: "Height",
                        value: getHeight(from: player.heightInInches),
                        gradient: [.orange, .red],
                        isCompact: true
                    )
                    
                    DetailCard(
                        icon: "scalemass",
                        title: "Weight",
                        value: "\(player.weightInPounds) lbs",
                        gradient: [.purple, .pink],
                        isCompact: true
                    )
                }
                
                if let draft = player.draftDetails {
                    DraftCard(draft: draft)
                } else {
                    UndraftedCard()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct DetailCard: View {
    let icon: String
    let title: String
    let value: String
    let gradient: [Color]
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: gradient),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: isCompact ? 12 : 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(isCompact ? 1 : 2)
            }
            
            if !isCompact {
                Spacer()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

struct DraftCard: View {
    let draft: NHLDraftDetails
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.yellow, .orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("Draft Information")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Selected by \(draft.teamAbbrev)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Overall Pick:")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("#\(draft.overallPick)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text("Round \(draft.round), Pick \(draft.pickInRound)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(removeCommas(from: "\(draft.year)"))")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

struct UndraftedCard: View {
    var body: some View {
        HStack {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.gray, .black]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
            
            VStack(alignment: .leading, spacing: 1) {
                Text("Undrafted")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Free agent signing")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

struct EnhancedPlayerStatsView: View {
    let player: NHLPlayer
    @Binding var selectedStatsType: StatsType
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Statistics")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.blue)
            }
            
            // Stats type selector
            StatsTypeSelector(selectedType: $selectedStatsType)
            
            if let seasonTotals = player.seasonTotals {
                let filteredStats = getFilteredStats(from: seasonTotals)
                
                if !filteredStats.isEmpty {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredStats, id: \.description) { season in
                            EnhancedStatsCard(season: season)
                        }
                    }
                } else {
                    EmptyStatsView()
                }
            } else {
                EmptyStatsView()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
    
    private func getFilteredStats(from stats: [NHLSeasonTotal]) -> [NHLSeasonTotal] {
        switch selectedStatsType {
        case .regular:
            return stats.filter { $0.gameTypeId == 2 }
                .sorted(by: { ($0.season ?? 0) > ($1.season ?? 0) })
        case .playoffs:
            return stats.filter { $0.gameTypeId == 3 }
                .sorted(by: { ($0.season ?? 0) > ($1.season ?? 0) })
        case .career:
            return stats.sorted(by: { ($0.season ?? 0) > ($1.season ?? 0) })
        }
    }
}

struct StatsTypeSelector: View {
    @Binding var selectedType: StatsType
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(StatsType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedType = type
                    }
                } label: {
                    Text(type.rawValue)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedType == type ? .white : .primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedType == type ?
                                    LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [.clear]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

struct EnhancedStatsCard: View {
    let season: NHLSeasonTotal
    
    var body: some View {
        VStack(spacing: 12) {
            // Season header
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(formatSeason(season.season))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Text(season.teamName?.def ?? "Unknown Team")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Text(season.leagueAbbrev ?? "N/A")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                            )
                    }
                }
                
                Spacer()
                
                if season.gameTypeId == 3 {
                    Text("PLAYOFFS")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.red, .orange]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                }
            }
            
            // Stats grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                StatBubble(title: "GP", value: "\(season.gamesPlayed ?? 0)", color: .blue)
                StatBubble(title: "G", value: "\(season.goals ?? 0)", color: .green)
                StatBubble(title: "A", value: "\(season.assists ?? 0)", color: .orange)
                StatBubble(title: "P", value: "\(season.points ?? 0)", color: .purple)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct StatBubble: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        )
    }
}

struct EmptyStatsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No statistics available")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct EnhancedLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            Text("Loading player data...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Helper Functions

func calculateAge(from dateString: String, with format: String = "yyyy-MM-dd") -> Int? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    
    guard let birthDate = dateFormatter.date(from: dateString) else {
        print("Invalid date string")
        return nil
    }
    
    let calendar = Calendar.current
    let currentDate = Date()
    let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
    
    return ageComponents.year
}

func getHeight(from heightInInches: Int) -> String {
    return "\(heightInInches / 12)′ \(heightInInches % 12)″"
}

private func daySuffix(num: Int) -> String {
    switch num % 10 {
    case 1 where num % 100 != 11: return "st"
    case 2 where num % 100 != 12: return "nd"
    case 3 where num % 100 != 13: return "rd"
    default: return "th"
    }
}

private func formatDate(_ dateString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    guard let date = dateFormatter.date(from: dateString) else { return dateString }
    dateFormatter.dateStyle = .long
    return dateFormatter.string(from: date)
}

func removeCommas(from numberString: String) -> String {
    return numberString.replacingOccurrences(of: ",", with: "")
}

func formatSeason(_ seasonInt: Int?) -> String {
    guard let seasonInt = seasonInt else { return "N/A" }
    let seasonStr = String(seasonInt)
    guard seasonStr.count == 8 else { return seasonStr }
    
    let startYear = seasonStr.prefix(4)
    let endYear = seasonStr.suffix(4)
    return "\(startYear)-\(endYear)"
}

struct CompareStatsSheet: View {
    let player1Id: Int
    
    @State private var availableSkaters: NHLPlayerSkaterStatsLeaders?
    @State private var availableGoalies: NHLPlayerGoalieStatsLeaders?
    
    @State private var isLoading = false
    @State private var showAlert = false
    
    @Binding var compareName: String
    var onSearch: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
         
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter another NHL player's name:")
                    .font(.headline)
                
                TextField("e.g. Sidney Crosby", text: $compareName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    isLoading = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if let matchedPlayerId = findMatchingPlayer(named: compareName) {
                            isLoading = false
                            onSearch(matchedPlayerId)
                            dismiss()
                        } else {
                            isLoading = false
                            showAlert = true
                        }
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    } else {
                        Text("Search and Compare")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Compare Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }.onAppear {
                decodeAvailableSkaters(season: "20242025", gameType: 2, statsType: "points")
                decodeAvailableGoalies(season: "20242025", gameType: 2, statsType: "wins")
            } .alert("Player Not Found", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("We couldn't find a player matching '\(compareName)'. Please try again.")
            }
        }
    }
    
    private func decodeAvailableSkaters(season: String, gameType: Int, statsType: String) {
        guard let url = NHLResource.skaterStatsLeadersURL(season: season, gameType: gameType, statsType: statsType) else {
            print("Cannot create available skaters stats URL for \(season)")
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print(error)
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let result = try decoder.decode(NHLPlayerSkaterStatsLeaders.self, from: data)
                DispatchQueue.main.async {
                    availableSkaters = result
                    
                }
            } catch {
                print(error)
            }
        }.resume()
    }

    private func decodeAvailableGoalies(season: String, gameType: Int, statsType: String) {
        guard let url = NHLResource.goalieStatsLeadersURL(season: season, gameType: gameType, statsType: statsType) else {
            print("Cannot create available goalie stats URL for \(season)")
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print(error)
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let result = try decoder.decode(NHLPlayerGoalieStatsLeaders.self, from: data)
                DispatchQueue.main.async {
                    availableGoalies = result
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    private func findMatchingPlayer(named name: String) -> Int? {
        // Search skaters
        if let skaters = availableSkaters?.points {
            if let skater = skaters.first(where: { normalized($0.fullName) == normalized(name) }) {
                return skater.playerId
            }
        }

        // Search goalies
        if let goalies = availableGoalies?.wins {
            if let goalie = goalies.first(where: { normalized($0.fullName) == normalized(name) }) {
                return goalie.playerId
            }
        }

        return nil
    }
    
    func normalized(_ name: String) -> String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
