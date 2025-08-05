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
    
    enum PlayerType: String, CaseIterable {
        case skater = "Skaters"
        case goalie = "Goalies"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                viewModel.filterPlayers(by: selectedPlayerType)
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
            
            // Player headshot
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
            Text("Try refreshing or check your connection")
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

            // Fetch full player data for each unique leader
            self.fetchFullPlayers(for: uniqueLeaders) { fullPlayers in
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
                self.filterPlayers(by: .skater)
                self.isLoading = false
            }
        }
    }


    // ✅ Fetch complete stats for a list of players
    private func fetchCompleteStats(for players: [NHLPlayerSkaterStats], completion: @escaping ([NHLPlayerSkaterStats]) -> Void) {
        let group = DispatchGroup()
        var results: [NHLPlayerSkaterStats] = []

        for player in players {
            group.enter()
            fetchPlayerStats(playerId: player.playerId) { fullStats in
                if let stats = fullStats {
                    results.append(stats)
                } else {
                    results.append(player) // fallback to partial
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }
    
    private func fetchFullPlayers(for leaders: [NHLPlayerSkaterStats], completion: @escaping ([NHLPlayerSkaterStats]) -> Void) {
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
                    if let stats = player.toSkaterStats(value: leader.value) {
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



    // ✅ Fetch full stats for a single player
    private func fetchPlayerStats(playerId: Int, completion: @escaping (NHLPlayerSkaterStats?) -> Void) {
        guard let url = NHLResource.basePlayerLandingURL(for: playerId) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { completion(nil); return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let stats = try decoder.decode(NHLPlayerSkaterStats.self, from: data)
                completion(stats)
            } catch {
                completion(nil)
            }
        }.resume()
    }

    // ✅ Merge two player stats objects without overwriting valid data
    private func mergeStats(base: NHLPlayerSkaterStats, extra: NHLPlayerSkaterStats) -> NHLPlayerSkaterStats {
        return NHLPlayerSkaterStats(
            playerId: base.playerId,
            firstName: base.firstName,
            lastName: base.lastName,
            sweaterNumber: base.sweaterNumber ?? extra.sweaterNumber,
            headshot: base.headshot.isEmpty ? extra.headshot : base.headshot,
            teamAbbrev: base.teamAbbrev.isEmpty ? extra.teamAbbrev : base.teamAbbrev,
            teamName: base.teamName,
            teamLogo: base.teamLogo.isEmpty ? extra.teamLogo : base.teamLogo,
            position: base.position.isEmpty ? extra.position : base.position,
            value: base.value > 0 ? base.value : extra.value,
            gamesPlayed: base.gamesPlayed ?? extra.gamesPlayed,
            goals: base.goals ?? extra.goals,
            assists: base.assists ?? extra.assists,
            points: base.points ?? extra.points,
            plusMinus: base.plusMinus ?? extra.plusMinus,
            pim: base.pim ?? extra.pim,
            wins: base.wins ?? extra.wins,
            losses: base.losses ?? extra.losses,
            shutouts: base.shutouts ?? extra.shutouts,
            savePctg: base.savePctg ?? extra.savePctg,
            goalsAgainstAvg: base.goalsAgainstAvg ?? extra.goalsAgainstAvg,
            calculatedRating: base.calculatedRating
        )
    }
    
    // REMOVED: fetchCompleteStats, fetchPlayerStats, mergePlayerStats functions
    // These were causing the problem by overwriting the good stats with empty data
    
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
    
    private func getSkatersList(from stats: NHLPlayerSkaterStatsLeaders, for type: String) -> [NHLPlayerSkaterStats] {
        switch type {
        case "goals": return stats.goals ?? []
        case "assists": return stats.assists ?? []
        case "points": return stats.points ?? []
        default: return []
        }
    }
    
    private func getGoalieList(from stats: NHLPlayerGoalieStatsLeaders, for type: String) -> [NHLPlayerSkaterStats] {
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
                    calculatedRating: nil
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
    
    func filterPlayers(by type: TopPlayersView.PlayerType) {
        switch type {
        case .skater:
            filteredPlayers = topPlayers.filter { player in
                player.position != "G"
            }
        case .goalie:
            filteredPlayers = topPlayers.filter { player in
                player.position == "G"
            }
        }
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
            calculatedRating: nil
        )
    }
}


