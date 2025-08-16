//
//  NHLOtherSeasonsView.swift
//  Rinkside
//
//  Created by Nik Bar on 8/13/25.
//

import SwiftUI

struct NHLOtherSeasonsView: View {
    @StateObject private var viewModel = NHLOtherSeasonsViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                NHLOtherSeasonsSearchBar(text: $searchText, placeholder: "Search tournaments...")
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Main content
                if viewModel.isLoading {
                    OtherSeasonsLoadingView()
                } else if viewModel.commonTournaments.isEmpty {
                    OtherSeasonsEmptyView()
                } else {
                    tournamentsList
                }
            }
            .navigationTitle("Other Seasons")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadCommonTournaments()
            }
            .onChange(of: searchText) { _ in
                viewModel.filterTournaments(searchText: searchText)
            }
        }
    }
    
    private var tournamentsList: some View {
        List {
            ForEach(viewModel.filteredTournaments, id: \.name) { tournament in
                TournamentRow(tournament: tournament)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            await viewModel.refreshData()
        }
    }
}

struct NHLOtherSeasonsSearchBar: View {
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

struct TournamentRow: View {
    let tournament: Tournament
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(tournament.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text("\(tournament.playerCount) players")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Tournament type indicator
                        if tournament.isOlympics {
                            Image(systemName: "medal.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text("Olympics")
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .fontWeight(.medium)
                        } else if tournament.isWorldCup {
                            Image(systemName: "globe")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("World Cup")
                                .font(.caption)
                                .foregroundColor(.orange)
                                .fontWeight(.medium)
                        } else if tournament.isInternational {
                            Image(systemName: "flag.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("International")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        } else if tournament.isNorthAmericanDevelopment {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("North America")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .fontWeight(.medium)
                        } else if tournament.isEuropeanLeague {
                            Image(systemName: "building.columns.fill")
                                .foregroundColor(.purple)
                                .font(.caption)
                            Text("European")
                                .font(.caption)
                                .foregroundColor(.purple)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            
            // Sample of seasons/years this tournament appeared in
            if !tournament.seasons.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tournament.seasons.sorted().reversed().prefix(5), id: \.self) { season in
                            NavigationLink(destination: NHLOtherSeasonsSpecificTopPlayersView(
                                leagueAbbrev: tournament.name,
                                season: season
                            )) {
                                Text(formatSeason(season))
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if tournament.seasons.count > 5 {
                            Text("+\(tournament.seasons.count - 5) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(.vertical, 4)
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

struct Tournament {
    let name: String
    let playerCount: Int
    let seasons: Set<Int>
    
    var isOlympics: Bool {
        name.uppercased().contains("OLYMPICS") ||
        name.uppercased().contains("OLYMPIC") ||
        name.uppercased().contains("OG")
    }
    
    var isWorldCup: Bool {
        name.uppercased().contains("WORLD CUP") ||
        name.uppercased().contains("WC") ||
        name.uppercased().contains("WORLD CHAMPIONSHIP")
    }
    
    var isInternational: Bool {
        name.uppercased().contains("WORLD") ||
        name.uppercased().contains("INTERNATIONAL") ||
        name.uppercased().contains("WJC") ||
        name.uppercased().contains("JUNIOR") ||
        name.uppercased().contains("IIHF") ||
        name.uppercased().contains("U20") ||
        name.uppercased().contains("U18") ||
        name.uppercased().contains("RUSSIA")
    }
    
    var isNorthAmericanDevelopment: Bool {
        let naLeagues = ["NHL", "AHL", "ECHL", "WHL", "OHL", "QMJHL", "CHL", "USHL", "NAHL", "BCHL", "NCAA"]
        return naLeagues.contains { league in
            name.uppercased().contains(league.uppercased())
        }
    }
    
    var isEuropeanLeague: Bool {
        let euroLeagues = ["KHL", "SHL", "LIIGA", "NLA", "DEL", "EXTRALIGA", "SM-LIIGA"]
        return euroLeagues.contains { league in
            name.uppercased().contains(league.uppercased())
        }
    }
}

struct OtherSeasonsLoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading tournaments...")
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

struct OtherSeasonsEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No tournaments found")
                .font(.title2)
                .fontWeight(.medium)
                .padding(.top, 16)
            Text("Try refreshing to load tournament data")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 4)
            Spacer()
        }
    }
}

// MARK: - ViewModel

class NHLOtherSeasonsViewModel: ObservableObject {
    @Published var commonTournaments: [Tournament] = []
    @Published var filteredTournaments: [Tournament] = []
    @Published var isLoading = false
    
    private let season = "20242025"
    private let gameType = 2
    private let minimumPlayers = 5 // Lowered from 20 for testing
    
    func loadCommonTournaments() {
        isLoading = true
        
        let group = DispatchGroup()
        var allPlayers: [NHLPlayerSkaterStats] = []
        
        // Fetch top players from various stat categories to get a good sample
        let skaterStatTypes = ["goals", "assists", "points"]
        for statType in skaterStatTypes {
            group.enter()
            loadSkaters(statType: statType) { skaters in
                allPlayers.append(contentsOf: skaters)
                group.leave()
            }
        }
        
        let goalieStatTypes = ["wins", "savePctg", "goalsAgainstAverage"]
        for statType in goalieStatTypes {
            group.enter()
            loadGoalies(statType: statType) { goalies in
                allPlayers.append(contentsOf: goalies)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Remove duplicates
            let uniquePlayers = self.removeDuplicates(from: allPlayers)
            print("Found \(uniquePlayers.count) unique players to analyze")
            
            // Fetch full player data for each unique player
            self.fetchFullPlayersData(for: uniquePlayers) { fullPlayers in
                print("Successfully fetched data for \(fullPlayers.count) players")
                
                // Analyze season totals to find common tournaments
                self.analyzeCommonTournaments(from: fullPlayers) { tournaments in
                    self.commonTournaments = tournaments.sorted { $0.playerCount > $1.playerCount }
                    self.filteredTournaments = self.commonTournaments
                    self.isLoading = false
                    print("Found \(tournaments.count) common tournaments")
                    
                    // Debug: Print found tournaments
                    for tournament in tournaments.prefix(10) {
                        print("Tournament: \(tournament.name) - \(tournament.playerCount) players - Seasons: \(tournament.seasons.count)")
                    }
                }
            }
        }
    }
    
    private func fetchFullPlayersData(for players: [NHLPlayerSkaterStats], completion: @escaping ([NHLPlayer]) -> Void) {
        let group = DispatchGroup()
        var results = [NHLPlayer]()
        let queue = DispatchQueue(label: "player.fetch.queue", attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 5) // Reduced concurrent requests to avoid rate limiting
        
        // Limit to first 50 players for testing to avoid overwhelming the API
        let limitedPlayers = Array(players.prefix(50))
        
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
                        DispatchQueue.main.async {
                            results.append(fullPlayer)
                        }
                        print("Successfully loaded player: \(fullPlayer.firstName.def ?? "") \(fullPlayer.lastName.def ?? "")")
                    } catch {
                        print("Decode error for player \(player.playerId): \(error)")
                    }
                }.resume()
            }
        }
        
        group.notify(queue: .main) {
            print("Completed fetching player data. Total players: \(results.count)")
            completion(results)
        }
    }
    
    private func analyzeCommonTournaments(from players: [NHLPlayer], completion: @escaping ([Tournament]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var tournamentPlayerCount: [String: Set<Int>] = [:]
            var tournamentSeasons: [String: Set<Int>] = [:]
            
            print("Analyzing tournaments from \(players.count) players...")
            
            for player in players {
                let playerName = "\(player.firstName.def) \(player.lastName.def)"
                print("Analyzing player: \(playerName) (ID: \(player.playerId))")
                
                // Check all season totals for this player
                if let seasonTotals = player.seasonTotals {
                    print("  Player has \(seasonTotals.count) season totals")
                    
                    for seasonTotal in seasonTotals {
                        // Extract league/tournament name
                        guard let leagueName = seasonTotal.leagueAbbrev,
                              !leagueName.isEmpty,
                              let season = seasonTotal.season else {
                            print("  Skipping entry - missing league name or season")
                            continue
                        }
                        
                        print("  Found league: \(leagueName) for season \(season)")
                        
                        // Track players and seasons for this tournament
                        if tournamentPlayerCount[leagueName] == nil {
                            tournamentPlayerCount[leagueName] = Set<Int>()
                            tournamentSeasons[leagueName] = Set<Int>()
                        }
                        
                        tournamentPlayerCount[leagueName]?.insert(player.playerId)
                        tournamentSeasons[leagueName]?.insert(season)
                    }
                } else {
                    print("  Player has no season totals")
                }
            }
            
            print("Tournament analysis complete. Found \(tournamentPlayerCount.count) unique tournaments:")
            for (name, players) in tournamentPlayerCount.sorted(by: { $0.value.count > $1.value.count }) {
                print("  \(name): \(players.count) players")
            }
            
            // Filter tournaments with at least minimum players and exclude NHL
            let commonTournaments = tournamentPlayerCount.compactMap { tournamentName, playerSet -> Tournament? in
                guard playerSet.count >= self.minimumPlayers,
                      tournamentName.uppercased() != "NHL" else { // Exclude NHL from "other seasons"
                    if tournamentName.uppercased() == "NHL" {
                        print("  Excluding NHL (has \(playerSet.count) players)")
                    } else {
                        print("  Excluding \(tournamentName) - only \(playerSet.count) players (minimum: \(self.minimumPlayers))")
                    }
                    return nil
                }
                
                print("  Including \(tournamentName) with \(playerSet.count) players")
                
                return Tournament(
                    name: tournamentName,
                    playerCount: playerSet.count,
                    seasons: tournamentSeasons[tournamentName] ?? Set<Int>()
                )
            }
            
            DispatchQueue.main.async {
                print("Returning \(commonTournaments.count) tournaments that meet minimum player threshold")
                for tournament in commonTournaments {
                    print("  Final tournament: \(tournament.name) - \(tournament.playerCount) players - \(tournament.seasons.count) seasons")
                }
                completion(commonTournaments)
            }
        }
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
                print("Loaded \(skaters.count) skaters for stat type: \(statType)")
                completion(skaters)
            } catch {
                print("Error decoding skaters: \(error)")
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
                print("Loaded \(goalies.count) goalies for stat type: \(statType)")
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
    
    func filterTournaments(searchText: String) {
        if searchText.isEmpty {
            filteredTournaments = commonTournaments
        } else {
            let searchLowercase = searchText.lowercased()
            filteredTournaments = commonTournaments.filter { tournament in
                tournament.name.lowercased().contains(searchLowercase)
            }
        }
    }
    
    func refreshData() async {
        await MainActor.run {
            loadCommonTournaments()
        }
    }
}

// MARK: - Preview

struct NHLOtherSeasonsView_Previews: PreviewProvider {
    static var previews: some View {
        NHLOtherSeasonsView()
    }
}
