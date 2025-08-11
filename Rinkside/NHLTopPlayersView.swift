//
//  TopPlayersView.swift
//  Rinkside
//
//  Created by Nik Bar on 7/13/25.
//

import SwiftUI

struct TopPlayersView: View {
    @StateObject private var viewModel = TopPlayersViewModel()
    @State private var selectedPlayerType: PlayerType = .skater
    @State private var searchText = ""
    
    enum PlayerType: String, CaseIterable {
        case skater = "Skaters"
        case goalie = "Goalies"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                TopPlayersSearchBar(text: $searchText, placeholder: "Search players...")
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Player type selector
                Picker("Player Type", selection: $selectedPlayerType) {
                    ForEach(PlayerType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Main content
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.topPlayers.isEmpty {
                    EmptyStateView()
                } else {
                    playersList
                }
            }
            .navigationTitle("Top Players")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadTopPlayers()
            }
            .onChange(of: selectedPlayerType) { _ in
                viewModel.filterPlayers(by: selectedPlayerType, searchText: searchText)
            }
            .onChange(of: searchText) { _ in
                viewModel.filterPlayers(by: selectedPlayerType, searchText: searchText)
            }
        }
    }
    
    private var playersList: some View {
        List {
            ForEach(Array(viewModel.filteredPlayers.enumerated()), id: \.element.id) { index, player in
                NavigationLink(destination: NHLPlayerView(playerId: player.toNHLPlayer().playerId)) {
                    PlayerRankingRow(player: player, rank: index + 1, playerType: selectedPlayerType)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            await viewModel.refreshData()
        }
    }
}

struct TopPlayersSearchBar: View {
    @Binding var text: String
    let placeholder: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        isEditing = true
                    }
                
                if !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if isEditing {
                Button("Cancel") {
                    isEditing = false
                    text = ""
                    hideKeyboard()
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}

// Extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct PlayerRankingRow: View {
    let player: NHLPlayerSkaterStats
    let rank: Int
    let playerType: TopPlayersView.PlayerType
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank number
            Text("\(rank)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .leading)
            
            // Player headshot with hot streak indicator
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: player.headshot)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                
                // Hot streak fire indicator
                if player.isOnHotStreak {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                        .background(Circle().fill(Color.white).frame(width: 20, height: 20))
                        .offset(x: 5, y: -5)
                }
            }
            
            // Player info and stats
            VStack(alignment: .leading, spacing: 4) {
                // Player name and team
                HStack {
                    Text("\(player.firstName.def) \(player.lastName.def)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    // Rating badge
                    RatingBadge(rating: player.calculatedRating ?? 75)
                }
                
                // Position and team
                HStack {
                    Text(player.position)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(player.teamAbbrev)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Stats based on player type
                if playerType == .skater {
                    SkaterStatsRow(player: player)
                } else {
                    GoalieStatsRow(player: player)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct SkaterStatsRow: View {
    let player: NHLPlayerSkaterStats
    
    var body: some View {
        HStack(spacing: 16) {
            StatItem(label: "G", value: "\(player.goals ?? 0)")
            StatItem(label: "A", value: "\(player.assists ?? 0)")
            StatItem(label: "P", value: "\(player.points ?? (player.goals ?? 0) + (player.assists ?? 0))")
            StatItem(label: "GP", value: "\(player.gamesPlayed ?? 0)")
            
            Spacer()
            
            // Points per game
            if let gp = player.gamesPlayed, gp > 0 {
                let points = player.points ?? ((player.goals ?? 0) + (player.assists ?? 0))
                let ppg = Double(points) / Double(gp)
                Text("\(ppg, specifier: "%.2f") PPG")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
            }
        }
    }
}

struct GoalieStatsRow: View {
    let player: NHLPlayerSkaterStats
    
    var body: some View {
        HStack(spacing: 16) {
            StatItem(label: "W", value: "\(player.wins ?? 0)")
            StatItem(label: "L", value: "\(player.losses ?? 0)")
            StatItem(label: "SO", value: "\(player.shutouts ?? 0)")
            StatItem(label: "GP", value: "\(player.gamesPlayed ?? 0)")
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if let savePct = player.savePctg {
                    Text("\(savePct, specifier: "%.3f") SV%")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
                
                if let gaa = player.goalsAgainstAvg {
                    Text("\(gaa, specifier: "%.2f") GAA")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
            }
        }
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 1) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .frame(minWidth: 24)
    }
}

struct RatingBadge: View {
    let rating: Int
    
    private var badgeColor: Color {
        switch rating {
        case 90...: return .purple
        case 85..<90: return .blue
        case 80..<85: return .green
        case 75..<80: return .orange
        case 70..<75: return .yellow
        default: return .gray
        }
    }
    
    var body: some View {
        Text("\(rating)")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading top players...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 16)
            Spacer()
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No players found")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.top, 16)
            Text("Try adjusting your search or filter")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            Spacer()
        }
    }
}

// MARK: - ViewModel

class TopPlayersViewModel: ObservableObject {
    @Published var topPlayers: [NHLPlayerSkaterStats] = []
    @Published var filteredPlayers: [NHLPlayerSkaterStats] = []
    @Published var isLoading = false

    private let season = "20242025"
    private let gameType = 2

    func loadTopPlayers() {
        isLoading = true

        let group = DispatchGroup()
        var allSkaters: [NHLPlayerSkaterStats] = []
        var allGoalies: [NHLPlayerSkaterStats] = []

        // Fetch skater leaders (goals, assists, points)
        let skaterStatTypes = ["goals", "assists", "points"]
        for statType in skaterStatTypes {
            group.enter()
            loadSkaters(statType: statType) { skaters in
                allSkaters.append(contentsOf: skaters)
                group.leave()
            }
        }

        // Fetch goalie leaders (wins, savePctg, goalsAgainstAverage)
        let goalieStatTypes = ["wins", "savePctg", "goalsAgainstAverage"]
        for statType in goalieStatTypes {
            group.enter()
            loadGoalies(statType: statType) { goalies in
                allGoalies.append(contentsOf: goalies)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            // Merge duplicates from different leaderboards
            let uniqueLeaders = self.removeDuplicates(from: allSkaters + allGoalies)

            // Fetch full player data for each unique leader including hot streak analysis
            self.fetchFullPlayersWithHotStreaks(for: uniqueLeaders) { fullPlayers in
                // Separate skaters and goalies
                let skaters = fullPlayers.filter { $0.position != "G" }
                let goalies = fullPlayers.filter { $0.position == "G" }

                // Calculate ratings
                let skatersWithRatings = self.calculateSkatersRatings(skaters)
                let goaliesWithRatings = self.calculateGoaliesRatings(goalies)

                // Combine & sort
                self.topPlayers = (skatersWithRatings + goaliesWithRatings)
                    .sorted { ($0.calculatedRating ?? 0) > ($1.calculatedRating ?? 0) }

                // Default filter to skaters
                self.filterPlayers(by: .skater, searchText: "")
                self.isLoading = false
            }
        }
    }
    
    private func fetchFullPlayersWithHotStreaks(for leaders: [NHLPlayerSkaterStats], completion: @escaping ([NHLPlayerSkaterStats]) -> Void) {
        let group = DispatchGroup()
        var results = [NHLPlayerSkaterStats]()
        
        for leader in leaders {
            group.enter()
            guard let url = NHLResource.basePlayerLandingURL(for: leader.playerId) else {
                group.leave(); continue
            }
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }
                guard let data = data else {
                    // If we can't fetch full player data, use the leader data we have
                    results.append(leader)
                    return
                }
                
                do {
                    // The NHL API returns the player object directly, not wrapped in a "player" key
                    let player = try JSONDecoder().decode(NHLPlayer.self, from: data)
                    if var stats = player.toSkaterStats(value: leader.value) {
                        // Determine hot streak status based on position
                        if stats.position == "G" {
                            stats.isOnHotStreak = self.isGoalieOnHotStreak(player.last5Games)
                        } else {
                            stats.isOnHotStreak = self.isSkaterOnHotStreak(player.last5Games)
                        }
                        results.append(stats)
                    } else {
                        // Fallback to leader data if conversion fails
                        results.append(leader)
                    }
                } catch {
                    print("Decode error for player \(leader.playerId): \(error)")
                    // Fallback to leader data if decode fails
                    results.append(leader)
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            completion(results)
        }
    }
    
    private func isSkaterOnHotStreak(_ last5Games: [NHLGameDetail]) -> Bool {
        guard !last5Games.isEmpty else { return false }
        
        let totalGoals = last5Games.compactMap { $0.goals }.reduce(0, +)
        let totalAssists = last5Games.compactMap { $0.assists }.reduce(0, +)
        let totalPoints = last5Games.compactMap { $0.points }.reduce(0, +)
        
        // Hot streak criteria for skaters:
        // 1. 1.5 times more points than games played (1.5 PPG over 5 games = 7.5+ points)
        // 2. 4 or more goals in last 5 games
        // 3. 6 or more assists in last 5 games
        let pointsThreshold = Int(1.5 * Double(last5Games.count))
        
        return totalPoints >= pointsThreshold || totalGoals >= 4 || totalAssists >= 6
    }
    
    private func isGoalieOnHotStreak(_ last5Games: [NHLGameDetail]) -> Bool {
        guard !last5Games.isEmpty else { return false }
        
        let gamesWithSavePct = last5Games.compactMap { $0.savePctg }
        let gamesWithGAA = last5Games.compactMap { $0.goalsAgainst }
        let wins = last5Games.filter { $0.decision == "W" }.count
        
        // Calculate average save percentage
        let avgSavePct = gamesWithSavePct.isEmpty ? 0.0 : gamesWithSavePct.reduce(0, +) / Double(gamesWithSavePct.count)
        
        // Calculate average goals against (GAA approximation)
        let avgGoalsAgainst = gamesWithGAA.isEmpty ? 0.0 : Double(gamesWithGAA.reduce(0, +)) / Double(gamesWithGAA.count)
        
        // Hot streak criteria for goalies:
        // 1. Average save percentage > 0.925 over last 5 games
        // 2. Average goals against < 1.75 over last 5 games
        // 3. Won all 5 games
        return avgSavePct > 0.925 || avgGoalsAgainst < 1.75 || wins == 5
    }
    
    private func loadSkaters(statType: String, completion: @escaping ([NHLPlayerSkaterStats]) -> Void) {
        guard let url = NHLResource.skaterStatsLeadersURL(season: season, gameType: gameType, statsType: statType) else {
            print("Cannot create skaters stats URL for \(statType)")
            completion([])
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading skaters: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("No data received for skaters")
                completion([])
                return
            }
            
            do {
                let result = try decoder.decode(NHLStatsLeadersAPIResponse.self, from: data)
                let apiStats = self.getSkatersListFromAPI(from: result, for: statType)
                let skaters = apiStats.map { $0.toNHLPlayerSkaterStats() }
                completion(skaters)
            } catch {
                print("Error decoding skaters: \(error)")
                // If that fails, try to decode the raw JSON to see the structure
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString.prefix(1000))") // First 1000 chars
                }
                completion([])
            }
        }.resume()
    }
    
    private func loadGoalies(statType: String, completion: @escaping ([NHLPlayerSkaterStats]) -> Void) {
        guard let url = NHLResource.goalieStatsLeadersURL(season: season, gameType: gameType, statsType: statType) else {
            print("Cannot create goalies stats URL for \(statType)")
            completion([])
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading goalies: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("No data received for goalies")
                completion([])
                return
            }
            
            do {
                let result = try decoder.decode(NHLGoalieStatsLeadersAPIResponse.self, from: data)
                let apiStats = self.getGoaliesListFromAPI(from: result, for: statType)
                let goalies = apiStats.map { $0.toNHLPlayerSkaterStats() }
                completion(goalies)
            } catch {
                print("Error decoding goalies: \(error)")
                // If that fails, try to decode the raw JSON to see the structure
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString.prefix(1000))") // First 1000 chars
                }
                completion([])
            }
        }.resume()
    }
    
    private func getSkatersListFromAPI(from stats: NHLStatsLeadersAPIResponse, for type: String) -> [NHLPlayerAPIStats] {
        switch type {
        case "goals": return stats.goals ?? []
        case "assists": return stats.assists ?? []
        case "points": return stats.points ?? []
        default: return []
        }
    }

    private func getGoaliesListFromAPI(from stats: NHLGoalieStatsLeadersAPIResponse, for type: String) -> [NHLPlayerAPIStats] {
        switch type {
        case "wins": return stats.wins ?? []
        case "savePctg": return stats.savePctg ?? []
        case "goalsAgainstAverage": return stats.goalsAgainstAverage ?? []
        default: return []
        }
    }
    
    private func removeDuplicates(from players: [NHLPlayerSkaterStats]) -> [NHLPlayerSkaterStats] {
        var playerDict: [Int: NHLPlayerSkaterStats] = [:]
        
        // When we encounter duplicates, merge the stats to keep the best data
        for player in players {
            if let existing = playerDict[player.playerId] {
                // Merge stats, keeping non-nil values
                let merged = NHLPlayerSkaterStats(
                    playerId: player.playerId,
                    firstName: player.firstName,
                    lastName: player.lastName,
                    sweaterNumber: player.sweaterNumber,
                    headshot: player.headshot,
                    teamAbbrev: player.teamAbbrev,
                    teamName: player.teamName,
                    teamLogo: player.teamLogo,
                    position: player.position,
                    value: player.value,
                    gamesPlayed: player.gamesPlayed ?? existing.gamesPlayed,
                    goals: player.goals ?? existing.goals,
                    assists: player.assists ?? existing.assists,
                    points: player.points ?? existing.points,
                    plusMinus: player.plusMinus ?? existing.plusMinus,
                    pim: player.pim ?? existing.pim,
                    wins: player.wins ?? existing.wins,
                    losses: player.losses ?? existing.losses,
                    shutouts: player.shutouts ?? existing.shutouts,
                    savePctg: player.savePctg ?? existing.savePctg,
                    goalsAgainstAvg: player.goalsAgainstAvg ?? existing.goalsAgainstAvg,
                    calculatedRating: nil,
                    isOnHotStreak: false
                )
                playerDict[player.playerId] = merged
            } else {
                playerDict[player.playerId] = player
            }
        }
        
        return Array(playerDict.values)
    }
    
    private func calculateSkatersRatings(_ skaters: [NHLPlayerSkaterStats]) -> [NHLPlayerSkaterStats] {
        // Convert to NHLSeasonTotal format for rating calculation
        let seasonTotalsWithPosition: [(season: NHLSeasonTotal, position: String?)] = skaters.compactMap { player in
            guard let season = convertToSeasonTotal(from: player) else { return nil }
            return (season, player.position)
        }
        
        // Calculate raw scores for all skaters (position-aware)
        let rawScores = seasonTotalsWithPosition.map { season, position in
            PlayerRatingEngine.calculateRawSkaterScore(for: season, position: position)
        }
        
        // Calculate mean and standard deviation
        let mean = rawScores.average()
        let stdDev = rawScores.standardDeviation()
        
        // Create updated players with ratings
        return zip(skaters, rawScores).map { player, rawScore in
            var updatedPlayer = player
            updatedPlayer.calculatedRating = PlayerRatingEngine.scaleToRating(rawScore: rawScore, mean: mean, stdDev: stdDev)
            return updatedPlayer
        }
    }

    
    private func calculateGoaliesRatings(_ goalies: [NHLPlayerSkaterStats]) -> [NHLPlayerSkaterStats] {
        // Convert to NHLSeasonTotal format for rating calculation
        let seasonTotals = goalies.compactMap { player -> NHLSeasonTotal? in
            return convertToSeasonTotal(from: player)
        }
        
        // Calculate raw scores for all goalies
        let rawScores = seasonTotals.map { PlayerRatingEngine.calculateRawGoalieScore(for: $0) }
        
        // Calculate mean and standard deviation
        let mean = rawScores.average()
        let stdDev = rawScores.standardDeviation()
        
        // Create updated players with ratings
        return zip(goalies, rawScores).map { player, rawScore in
            var updatedPlayer = player
            updatedPlayer.calculatedRating = PlayerRatingEngine.scaleToRating(rawScore: rawScore, mean: mean, stdDev: stdDev)
            return updatedPlayer
        }
    }
    
    private func convertToSeasonTotal(from player: NHLPlayerSkaterStats) -> NHLSeasonTotal? {
        return NHLSeasonTotal(
            gameTypeId: 2,
            gamesPlayed: player.gamesPlayed,
            goalsAgainstAvg: player.goalsAgainstAvg,
            goalsAgainst: nil,
            leagueAbbrev: "NHL",
            savePctg: player.savePctg,
            season: 20242025,
            sequence: 1,
            losses: player.losses,
            wins: player.wins,
            ties: nil,
            timeOnIce: nil,
            shutouts: player.shutouts,
            teamName: player.teamName,
            assists: player.assists,
            goals: player.goals,
            points: player.points,
            pim: player.pim,
            otLosses: nil,
            teamPlaceNameWithPreposition: nil,
            plusMinus: player.plusMinus,
            gamesStarted: nil
        )
    }
    
    func filterPlayers(by type: TopPlayersView.PlayerType, searchText: String) {
        // First filter by player type
        var playersToFilter: [NHLPlayerSkaterStats]
        switch type {
        case .skater:
            playersToFilter = topPlayers.filter { $0.position != "G" }
        case .goalie:
            playersToFilter = topPlayers.filter { $0.position == "G" }
        }
        
        // Then apply search filter if search text is not empty
        if !searchText.isEmpty {
            let searchLowercase = searchText.lowercased()
            playersToFilter = playersToFilter.filter { player in
                let fullName = "\(player.firstName.def) \(player.lastName.def)".lowercased()
                let firstName = player.firstName.def.lowercased()
                let lastName = player.lastName.def.lowercased()
                let teamName = player.teamAbbrev.lowercased()
                
                return fullName.contains(searchLowercase) ||
                       firstName.contains(searchLowercase) ||
                       lastName.contains(searchLowercase) ||
                       teamName.contains(searchLowercase)
            }
        }
        
        filteredPlayers = playersToFilter
    }
    
    func refreshData() async {
        await MainActor.run {
            loadTopPlayers()
        }
    }
}

// MARK: - Preview

struct TopPlayersView_Previews: PreviewProvider {
    static var previews: some View {
        TopPlayersView()
    }
}


struct NHLStatsLeadersAPIResponse: Codable {
    let goals: [NHLPlayerAPIStats]?
    let assists: [NHLPlayerAPIStats]?
    let points: [NHLPlayerAPIStats]?
}

struct NHLGoalieStatsLeadersAPIResponse: Codable {
    let wins: [NHLPlayerAPIStats]?
    let savePctg: [NHLPlayerAPIStats]?
    let goalsAgainstAverage: [NHLPlayerAPIStats]?
}

// This struct matches what the NHL API actually returns
struct NHLPlayerAPIStats: Codable {
    let id: Int  // The NHL API uses "id" not "playerId"
    let firstName: NHLType
    let lastName: NHLType
    let sweaterNumber: Int?
    let headshot: String
    let teamAbbrev: String
    let teamName: NHLType
    let teamLogo: String
    let position: String
    let value: Double  // This is the stat value (assists, goals, etc.)
    
    // These fields might not be present in the stats leaders API
    let gamesPlayed: Int?
    let goals: Int?
    let assists: Int?
    let points: Int?
    let plusMinus: Int?
    let pim: Int?
    let wins: Int?
    let losses: Int?
    let shutouts: Int?
    let savePctg: Double?
    let goalsAgainstAvg: Double?
    
    // Convert to your internal model
    func toNHLPlayerSkaterStats() -> NHLPlayerSkaterStats {
        return NHLPlayerSkaterStats(
            playerId: id,
            firstName: firstName,
            lastName: lastName,
            sweaterNumber: sweaterNumber,
            headshot: headshot,
            teamAbbrev: teamAbbrev,
            teamName: teamName,
            teamLogo: teamLogo,
            position: position,
            value: value,
            gamesPlayed: gamesPlayed,
            goals: goals,
            assists: assists,
            points: points,
            plusMinus: plusMinus,
            pim: pim,
            wins: wins,
            losses: losses,
            shutouts: shutouts,
            savePctg: savePctg,
            goalsAgainstAvg: goalsAgainstAvg,
            calculatedRating: nil,
            isOnHotStreak: false
        )
    }
}
