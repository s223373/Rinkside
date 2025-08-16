//
//  NHLOtherSeasonsSpecificTopPlayersView.swift
//  Rinkside
//
//  Created by Nik Bar on 8/16/25.
//

import SwiftUI

struct NHLOtherSeasonsSpecificTopPlayersView: View {
    let leagueAbbrev: String
    let season: Int
    
    @StateObject private var viewModel = NHLOtherSeasonsSpecificTopPlayersViewModel()
    @State private var selectedPlayerType: PlayerType = .skater
    @State private var searchText = ""
    
    enum PlayerType: String, CaseIterable {
        case skater = "Skaters"
        case goalie = "Goalies"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // League and season info header
                VStack(spacing: 4) {
                    Text(leagueAbbrev)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(formatSeason(season))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                
                // Search bar
                OtherSeasonsSpecificSearchBar(text: $searchText, placeholder: "Search players...")
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
                    OtherSeasonsSpecificLoadingView()
                } else if viewModel.topPlayers.isEmpty {
                    OtherSeasonsSpecificEmptyView()
                } else {
                    playersList
                }
            }
            .navigationTitle("League Leaders")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadTopPlayers(for: leagueAbbrev, season: season)
            }
            .onChange(of: selectedPlayerType) { _ in
                viewModel.filterPlayers(by: selectedPlayerType, searchText: searchText)
            }
            .onChange(of: searchText) { _ in
                viewModel.filterPlayers(by: selectedPlayerType, searchText: searchText)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevents navigation view nesting issues
    }
    
    private var playersList: some View {
        List {
            ForEach(Array(viewModel.filteredPlayers.enumerated()), id: \.element.id) { index, player in
                NavigationLink(destination: NHLPlayerView(playerId: player.playerId)) {
                    OtherSeasonsSpecificPlayerRow(player: player, rank: index + 1, playerType: selectedPlayerType)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            await viewModel.refreshData(for: leagueAbbrev, season: season)
        }
    }
    
    private func formatSeason(_ season: Int) -> String {
        if season < 1000 {
            return "\(season)"
        }
        let startYear = season / 10000
        let endYear = season % 10000
        return "\(startYear)-\(String(endYear).suffix(2))"
    }
}

struct OtherSeasonsSpecificSearchBar: View {
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

struct OtherSeasonsSpecificPlayerRow: View {
    let player: OtherSeasonsPlayer
    let rank: Int
    let playerType: NHLOtherSeasonsSpecificTopPlayersView.PlayerType
    
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
                }
                
                // Position and team
                HStack {
                    Text(player.position)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let teamName = player.teamName {
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(teamName.def)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Stats based on player type
                if playerType == .skater {
                    OtherSeasonsSpecificSkaterStatsRow(player: player)
                } else {
                    OtherSeasonsSpecificGoalieStatsRow(player: player)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct OtherSeasonsSpecificSkaterStatsRow: View {
    let player: OtherSeasonsPlayer
    
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

struct OtherSeasonsSpecificGoalieStatsRow: View {
    let player: OtherSeasonsPlayer
    
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

struct OtherSeasonsSpecificLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading league leaders...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 16)
            Text("This may take a moment")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            Spacer()
        }
    }
}

struct OtherSeasonsSpecificEmptyView: View {
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
            Text("No data available for this league and season")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            Spacer()
        }
    }
}

// MARK: - Data Models

struct OtherSeasonsPlayer: Identifiable {
    let id: Int
    let playerId: Int
    let firstName: NHLType
    let lastName: NHLType
    let position: String
    let headshot: String
    let teamName: NHLType?
    let gamesPlayed: Int?
    let goals: Int?
    let assists: Int?
    let points: Int?
    let wins: Int?
    let losses: Int?
    let shutouts: Int?
    let savePctg: Double?
    let goalsAgainstAvg: Double?
    let pim: Int?
    let plusMinus: Int?
    
    init(from player: NHLPlayer, seasonTotal: NHLSeasonTotal) {
        self.id = player.playerId
        self.playerId = player.playerId
        self.firstName = player.firstName
        self.lastName = player.lastName
        self.position = player.position
        self.headshot = player.headshot
        self.teamName = seasonTotal.teamName
        self.gamesPlayed = seasonTotal.gamesPlayed
        self.goals = seasonTotal.goals
        self.assists = seasonTotal.assists
        self.points = seasonTotal.points
        self.wins = seasonTotal.wins
        self.losses = seasonTotal.losses
        self.shutouts = seasonTotal.shutouts
        self.savePctg = seasonTotal.savePctg
        self.goalsAgainstAvg = seasonTotal.goalsAgainstAvg
        self.pim = seasonTotal.pim
        self.plusMinus = seasonTotal.plusMinus
    }
}

// MARK: - ViewModel

class NHLOtherSeasonsSpecificTopPlayersViewModel: ObservableObject {
    @Published var topPlayers: [OtherSeasonsPlayer] = []
    @Published var filteredPlayers: [OtherSeasonsPlayer] = []
    @Published var isLoading = false
    
    private let minimumGames = 5 // Minimum games played to be included
    
    func loadTopPlayers(for leagueAbbrev: String, season: Int) {
        isLoading = true
        
        // First, get a sample of current NHL players to analyze
        let group = DispatchGroup()
        var allPlayers: [NHLPlayerSkaterStats] = []
        
        // Fetch top players from various stat categories to get a good sample
        let skaterStatTypes = ["goals", "assists", "points"]
        for statType in skaterStatTypes {
            group.enter()
            loadCurrentNHLSkaters(statType: statType) { skaters in
                allPlayers.append(contentsOf: skaters)
                group.leave()
            }
        }
        
        let goalieStatTypes = ["wins", "savePctg", "goalsAgainstAverage"]
        for statType in goalieStatTypes {
            group.enter()
            loadCurrentNHLGoalies(statType: statType) { goalies in
                allPlayers.append(contentsOf: goalies)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Remove duplicates
            let uniquePlayers = self.removeDuplicates(from: allPlayers)
            print("Found \(uniquePlayers.count) unique NHL players to analyze for \(leagueAbbrev) \(season)")
            
            // Fetch full player data and filter by league/season
            self.fetchPlayersForSpecificLeagueSeason(
                players: uniquePlayers,
                leagueAbbrev: leagueAbbrev,
                season: season
            ) { leagueSpecificPlayers in
                print("Found \(leagueSpecificPlayers.count) players who played in \(leagueAbbrev) during \(season)")
                
                // Sort by points (skaters) or wins (goalies)
                let sortedPlayers = leagueSpecificPlayers.sorted { player1, player2 in
                    if player1.position == "G" && player2.position == "G" {
                        // For goalies, sort by wins first, then by save percentage
                        if let wins1 = player1.wins, let wins2 = player2.wins, wins1 != wins2 {
                            return wins1 > wins2
                        }
                        return (player1.savePctg ?? 0.0) > (player2.savePctg ?? 0.0)
                    } else if player1.position != "G" && player2.position != "G" {
                        // For skaters, sort by points
                        let points1 = player1.points ?? ((player1.goals ?? 0) + (player1.assists ?? 0))
                        let points2 = player2.points ?? ((player2.goals ?? 0) + (player2.assists ?? 0))
                        return points1 > points2
                    } else {
                        // Mixed comparison - skaters before goalies
                        return player1.position != "G"
                    }
                }
                
                self.topPlayers = sortedPlayers
                
                // Default filter to skaters
                self.filterPlayers(by: .skater, searchText: "")
                self.isLoading = false
            }
        }
    }
    
    private func fetchPlayersForSpecificLeagueSeason(
        players: [NHLPlayerSkaterStats],
        leagueAbbrev: String,
        season: Int,
        completion: @escaping ([OtherSeasonsPlayer]) -> Void
    ) {
        let group = DispatchGroup()
        var results = [OtherSeasonsPlayer]()
        let queue = DispatchQueue(label: "league.specific.fetch.queue", attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 5) // Limit concurrent requests
        
        // Limit to first 100 players for performance
        let limitedPlayers = Array(players.prefix(100))
        
        for player in limitedPlayers {
            group.enter()
            queue.async {
                semaphore.wait()
                
                guard let url = NHLResource.basePlayerLandingURL(for: player.playerId) else {
                    print("Could not create URL for player \(player.playerId)")
                    semaphore.signal()
                    group.leave()
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    defer {
                        semaphore.signal()
                        group.leave()
                    }
                    
                    if let error = error {
                        print("Error fetching player \(player.playerId): \(error)")
                        return
                    }
                    
                    guard let data = data else {
                        print("No data for player \(player.playerId)")
                        return
                    }
                    
                    do {
                        let fullPlayer = try JSONDecoder().decode(NHLPlayer.self, from: data)
                        
                        // Find matching season totals for the specific league and season
                        if let seasonTotals = fullPlayer.seasonTotals {
                            for seasonTotal in seasonTotals {
                                if let totalLeague = seasonTotal.leagueAbbrev,
                                   let totalSeason = seasonTotal.season,
                                   totalLeague == leagueAbbrev && totalSeason == season,
                                   let gamesPlayed = seasonTotal.gamesPlayed,
                                   gamesPlayed >= self.minimumGames {
                                    
                                    let otherSeasonsPlayer = OtherSeasonsPlayer(
                                        from: fullPlayer,
                                        seasonTotal: seasonTotal
                                    )
                                    
                                    DispatchQueue.main.async {
                                        results.append(otherSeasonsPlayer)
                                    }
                                    break // Only add the first matching season total
                                }
                            }
                        }
                    } catch {
                        print("Decode error for player \(player.playerId): \(error)")
                    }
                }.resume()
            }
        }
        
        group.notify(queue: .main) {
            print("Completed fetching league-specific player data. Total players: \(results.count)")
            completion(results)
        }
    }
    
    private func loadCurrentNHLSkaters(statType: String, completion: @escaping ([NHLPlayerSkaterStats]) -> Void) {
        guard let url = NHLResource.skaterStatsLeadersURL(season: "20242025", gameType: 2, statsType: statType) else {
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
                completion([])
            }
        }.resume()
    }
    
    private func loadCurrentNHLGoalies(statType: String, completion: @escaping ([NHLPlayerSkaterStats]) -> Void) {
        guard let url = NHLResource.goalieStatsLeadersURL(season: "20242025", gameType: 2, statsType: statType) else {
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
        
        for player in players {
            if playerDict[player.playerId] == nil {
                playerDict[player.playerId] = player
            }
        }
        
        return Array(playerDict.values)
    }
    
    func filterPlayers(by type: NHLOtherSeasonsSpecificTopPlayersView.PlayerType, searchText: String) {
        // First filter by player type
        var playersToFilter: [OtherSeasonsPlayer]
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
                let teamName = player.teamName?.def.lowercased() ?? ""
                
                return fullName.contains(searchLowercase) ||
                       firstName.contains(searchLowercase) ||
                       lastName.contains(searchLowercase) ||
                       teamName.contains(searchLowercase)
            }
        }
        
        filteredPlayers = playersToFilter
    }
    
    func refreshData(for leagueAbbrev: String, season: Int) async {
        await MainActor.run {
            loadTopPlayers(for: leagueAbbrev, season: season)
        }
    }
}

// MARK: - Preview

struct NHLOtherSeasonsSpecificTopPlayersView_Previews: PreviewProvider {
    static var previews: some View {
        NHLOtherSeasonsSpecificTopPlayersView(leagueAbbrev: "KHL", season: 20112012)
    }
}
