//
//  NHLTeamScheduleView.swift
//  Rinkside
//
//  Created by Nik Bar on 12/22/24.
//

import SwiftUI

struct NHLTeamScheduleView: View {
    @State private var teamSchedule: NHLTeamSchedule?
    @State private var isLoading: Bool = true
    @State private var selectedFilter: ScheduleFilter = .all
    
    private let teamId: String
    
    public init(teamIdentifier: String) {
        teamId = teamIdentifier
    }
    
    enum ScheduleFilter: String, CaseIterable {
        case all = "All Games"
        case regularSeason = "Regular Season"
        case preseason = "Preseason"
        case upcoming = "Upcoming"
        case completed = "Completed"
        case wins = "Wins"
        case losses = "Losses"
    }
    
    var filteredGames: [NHLGame] {
        guard let games = teamSchedule?.games else { return [] }
        
        switch selectedFilter {
        case .all:
            return games
        case .regularSeason:
            return games.suffix(82)
        case .preseason:
            return games.count > 82 ? Array(games.prefix(games.count - 82)) : []
        case .upcoming:
            return games.filter { ($0.homeTeam.score ?? -1) == -1 && ($0.awayTeam.score ?? -1) == -1 }
        case .completed:
            return games.filter { ($0.homeTeam.score ?? -1) != -1 || ($0.awayTeam.score ?? -1) != -1 }
        case .wins:
            return games.filter { isWin(game: $0) }
        case .losses:
            return games.filter { isLoss(game: $0) }
        }
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
            
            VStack(spacing: 0) {
                // Filter picker
                if !isLoading {
                    VStack(spacing: 16) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ScheduleFilter.allCases, id: \.self) { filter in
                                    FilterButton(
                                        title: filter.rawValue,
                                        isSelected: selectedFilter == filter,
                                        count: countForFilter(filter)
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedFilter = filter
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                }
                
                if isLoading {
                    Spacer()
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        Text("Loading Schedule...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else if filteredGames.isEmpty {
                    Spacer()
                    EmptyStateView(filter: selectedFilter)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(filteredGames.enumerated()), id: \.offset) { index, game in
                                GameCardView(
                                    game: game,
                                    teamId: teamId,
                                    gameNumber: getGameNumber(for: game, in: filteredGames, at: index),
                                    seasonType: getSeasonType(for: game)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .refreshable {
                        await refreshSchedule()
                    }
                }
            }
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if teamSchedule == nil {
                decodeTeamSchedule()
            }
        }
    }
    
    private func countForFilter(_ filter: ScheduleFilter) -> Int {
        guard let games = teamSchedule?.games else { return 0 }
        
        switch filter {
        case .all:
            return games.count
        case .regularSeason:
            return min(games.count, 82)
        case .preseason:
            return games.count > 82 ? games.count - 82 : 0
        case .upcoming:
            return games.filter { ($0.homeTeam.score ?? -1) == -1 && ($0.awayTeam.score ?? -1) == -1 }.count
        case .completed:
            return games.filter { ($0.homeTeam.score ?? -1) != -1 || ($0.awayTeam.score ?? -1) != -1 }.count
        case .wins:
            return games.filter { isWin(game: $0) }.count
        case .losses:
            return games.filter { isLoss(game: $0) }.count
        }
    }
    
    private func getGameNumber(for game: NHLGame, in filteredGames: [NHLGame], at index: Int) -> Int {
        guard let allGames = teamSchedule?.games else { return index + 1 }
        
        // Find the game's position in the original schedule
        if let originalIndex = allGames.firstIndex(where: { $0.id == game.id }) {
            if originalIndex >= allGames.count - 82 {
                // Regular season game
                return originalIndex - (allGames.count - 82) + 1
            } else {
                // Preseason game
                return originalIndex + 1
            }
        }
        
        return index + 1
    }
    
    private func getSeasonType(for game: NHLGame) -> SeasonType {
        guard let allGames = teamSchedule?.games else { return .regular }
        
        if let gameIndex = allGames.firstIndex(where: { $0.id == game.id }) {
            return gameIndex >= allGames.count - 82 ? .regular : .preseason
        }
        
        return .regular
    }
    
    private func isWin(game: NHLGame) -> Bool {
        if game.homeTeam.abbrev == teamId {
            return (game.homeTeam.score ?? -1) > (game.awayTeam.score ?? -1)
        } else if game.awayTeam.abbrev == teamId {
            return (game.awayTeam.score ?? -1) > (game.homeTeam.score ?? -1)
        }
        return false
    }
    
    private func isLoss(game: NHLGame) -> Bool {
        if game.homeTeam.abbrev == teamId {
            return (game.homeTeam.score ?? -1) < (game.awayTeam.score ?? -1) && (game.homeTeam.score ?? -1) != -1
        } else if game.awayTeam.abbrev == teamId {
            return (game.awayTeam.score ?? -1) < (game.homeTeam.score ?? -1) && (game.awayTeam.score ?? -1) != -1
        }
        return false
    }
    
    private func refreshSchedule() async {
        isLoading = true
        decodeTeamSchedule()
    }
    
    private func decodeTeamSchedule() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let url = NHLResource.baseTeamScheduleURL(for: teamId) else {
            print("Invalid URL")
            DispatchQueue.main.async {
                isLoading = false
            }
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { dataW, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching schedule: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
                guard let dataL = dataW else {
                    print("No data received")
                    isLoading = false
                    return
                }
                
                do {
                    let result = try decoder.decode(NHLTeamSchedule.self, from: dataL)
                    teamSchedule = result
                    isLoading = false
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Missing key: \(key.stringValue) – \(context.debugDescription)")
                    isLoading = false
                } catch let DecodingError.typeMismatch(_, context) {
                    print("Type mismatch – \(context.debugDescription)")
                    isLoading = false
                } catch let error {
                    print("Failed to decode: \(error)")
                    isLoading = false
                }
            }
        }
        dataTask.resume()
    }
}

enum SeasonType {
    case preseason, regular
    
    var displayName: String {
        switch self {
        case .preseason: return "Preseason"
        case .regular: return "Regular Season"
        }
    }
    
    var color: Color {
        switch self {
        case .preseason: return .orange
        case .regular: return .blue
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isSelected ? .white : .blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.white.opacity(0.3) : Color.blue.opacity(0.1))
                        )
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct GameCardView: View {
    let game: NHLGame
    let teamId: String
    let gameNumber: Int
    let seasonType: SeasonType
    
    var gameStatus: GameStatus {
        if (game.homeTeam.score ?? -1) == -1 && (game.awayTeam.score ?? -1) == -1 {
            return .upcoming
        } else if game.homeTeam.score == game.awayTeam.score {
            return .tie
        } else if isWin {
            return .win
        } else {
            return .loss
        }
    }
    
    var isWin: Bool {
        if game.homeTeam.abbrev == teamId {
            return (game.homeTeam.score ?? -1) > (game.awayTeam.score ?? -1)
        } else if game.awayTeam.abbrev == teamId {
            return (game.awayTeam.score ?? -1) > (game.homeTeam.score ?? -1)
        }
        return false
    }
    
    enum GameStatus {
        case upcoming, win, loss, tie
        
        var color: Color {
            switch self {
            case .upcoming: return .blue
            case .win: return .green
            case .loss: return .red
            case .tie: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .upcoming: return "clock"
            case .win: return "checkmark.circle.fill"
            case .loss: return "xmark.circle.fill"
            case .tie: return "equal.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationLink(destination: NHLBoxscoreView(gameId: game.id)) {
            VStack(spacing: 16) {
                // Game header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("\(seasonType.displayName) Game \(gameNumber)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            // Season type indicator
                            Text(seasonType.displayName.prefix(1))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 16, height: 16)
                                .background(
                                    Circle()
                                        .fill(seasonType.color)
                                )
                        }
                        
                        Text(formattedDate(from: game.gameDate))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: gameStatus.icon)
                            .foregroundColor(gameStatus.color)
                        
                        Text(gameStatus == .upcoming ? "Upcoming" :
                             gameStatus == .win ? "Win" :
                             gameStatus == .loss ? "Loss" : "Tie")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(gameStatus.color)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(gameStatus.color.opacity(0.1))
                    )
                }
                
                // Teams and score
                HStack(spacing: 20) {
                    // Away team
                    VStack(spacing: 8) {
                        teamLogo(for: game.awayTeam.abbrev)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        Text(game.awayTeam.abbrev)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    // Score or vs
                    VStack(spacing: 4) {
                        if gameStatus == .upcoming {
                            Text("VS")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(game.awayTeam.score ?? 0) - \(game.homeTeam.score ?? 0)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        if gameStatus != .upcoming {
                            Text("Final")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Home team
                    VStack(spacing: 8) {
                        teamLogo(for: game.homeTeam.abbrev)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        Text(game.homeTeam.abbrev)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(seasonType.color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func teamLogo(for teamId: String) -> Image {
        if let uiImage = UIImage(named: teamId) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "sportscourt.fill")
        }
    }
    
    private func formattedDate(from isoDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: isoDate) else {
            return isoDate
        }
        
        let day = Calendar.current.component(.day, from: date)
        let suffix = daySuffix(day: day)
        
        return outputFormatter.string(from: date) + suffix
    }
    
    private func daySuffix(day: Int) -> String {
        switch day {
        case 11...13:
            return "th"
        default:
            switch day % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }
}

struct EmptyStateView: View {
    let filter: NHLTeamScheduleView.ScheduleFilter
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Games Found")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("No games match the \(filter.rawValue.lowercased()) filter")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }
}
