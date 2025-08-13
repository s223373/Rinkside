//
//  NHLFantasyDraftView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/19/25.
//

import SwiftUI

struct NHLFantasyDraftView: View {
    @State private var allAvailableSkaters: [NHLPlayerSkaterStats] = []
    @State private var allAvailableGoalies: [NHLPlayerSkaterStats] = []
    
    @State private var showBackConfirmation = false
    @Environment(\.presentationMode) var presentationMode
    
    @State private var timeRemaining = 60
    @State private var timer: Timer? = nil

    @State private var availableSkaters: NHLStatsLeadersAPIResponse?
    @State private var availableGoalies: NHLGoalieStatsLeadersAPIResponse?
    @State private var isSkaterLoading: Bool = true
    @State private var isGoalieLoading: Bool = true
    @State private var selectedSkaterCategory: String = "Goals"
    @State private var selectedGoalieCategory: String = "Wins"

    @State private var season: String = "20242025"
    @State private var gameType: Int = 2
    @State private var statsSkaterType: String = "goals"
    @State private var statsGoalieType: String = "wins"
    
    @State private var lastSelectedPlayer: NHLPlayerSkaterStats? = nil
    @State private var lastCPUSelections: [(teamName: String, player: NHLPlayerSkaterStats)] = []
    @State private var lastCPUPlayer: (teamName: String, player: NHLPlayerSkaterStats)? = nil
    
    @State private var showPositionLimitAlert = false
    @State private var positionLimitMessage = ""
    
    // Draft turn management
    @State private var currentDraftTurn: Int = 0
    @State private var isProcessingCPUTurn = false

    private var fantasyTeam: NHLFantasyTeam
    private var fantasyLeague: NHLFantasyTeamLeague
    
    // Draft limits
    private let maxSkaters = 23
    private let minForwards = 12
    private let minDefensemen = 6
    private let maxGoalies = 3
    
    // Calculated maximums based on team size constraints
    private var maxForwards: Int {
        // Max forwards = total skaters - minimum defensemen required
        return maxSkaters - minDefensemen // 23 - 6 = 17
    }
    
    private var maxDefensemen: Int {
        // Max defensemen = total skaters - minimum forwards required
        return maxSkaters - minForwards // 23 - 12 = 11
    }
    
    private var forwardsCount: Int {
        fantasyTeam.draftedPlayers.filter {
            $0.position == "F" || $0.position == "C" || $0.position == "L" || $0.position == "R"
        }.count
    }
    
    private var defensemenCount: Int {
        fantasyTeam.draftedPlayers.filter { $0.position == "D" }.count
    }

    private var skatersCount: Int {
        fantasyTeam.draftedPlayers.filter { $0.position != "G" }.count
    }

    private var goaliesCount: Int {
        fantasyTeam.draftedPlayers.filter { $0.position == "G" }.count
    }

    private var draftComplete: Bool {
        skatersCount >= maxSkaters &&
        forwardsCount >= minForwards &&
        defensemenCount >= minDefensemen &&
        goaliesCount >= maxGoalies
    }
    
    // Get the current team whose turn it is
    private var currentTeam: NHLFantasyTeam {
        let teamIndex = currentDraftTurn % fantasyLeague.teams.count
        return fantasyLeague.teams[teamIndex]
    }
    
    // Check if it's the human player's turn
    private var isHumanTurn: Bool {
        let teamIndex = currentDraftTurn % fantasyLeague.teams.count
        return fantasyLeague.teams[teamIndex].id == fantasyTeam.id
    }
    
    // Get the human player's team index
    private var humanTeamIndex: Int {
        return fantasyLeague.teams.firstIndex(where: { $0.id == fantasyTeam.id }) ?? 0
    }
    
    // Helper function to check if a player can be drafted
    private func canDraftPlayer(_ player: NHLPlayerSkaterStats) -> Bool {
        if player.position == "G" {
            return goaliesCount < maxGoalies
        } else if player.position == "D" {
            return defensemenCount < maxDefensemen && skatersCount < maxSkaters
        } else if ["F", "C", "L", "R"].contains(player.position) {
            return forwardsCount < maxForwards && skatersCount < maxSkaters
        }
        return false
    }
    
    // Helper function to get position limit message
    private func getPositionLimitMessage(for player: NHLPlayerSkaterStats) -> String {
        if player.position == "G" {
            return "You've reached the maximum number of goalies (\(maxGoalies)). You cannot draft any more goalies."
        } else if player.position == "D" {
            if defensemenCount >= maxDefensemen {
                return "You've reached the maximum number of defensemen (\(maxDefensemen)). You cannot draft any more defensemen."
            } else if skatersCount >= maxSkaters {
                return "You've reached the maximum number of skaters (\(maxSkaters)). You cannot draft any more skaters."
            }
        } else if ["F", "C", "L", "R"].contains(player.position) {
            if forwardsCount >= maxForwards {
                return "You've reached the maximum number of forwards (\(maxForwards)). You cannot draft any more forwards."
            } else if skatersCount >= maxSkaters {
                return "You've reached the maximum number of skaters (\(maxSkaters)). You cannot draft any more skaters."
            }
        }
        return "You cannot draft this player."
    }
    
    private var availableForwards: [NHLPlayerSkaterStats] {
        allAvailableSkaters.filter {
            ["F", "C", "L", "R"].contains($0.position)
        }
    }

    private var availableDefensemen: [NHLPlayerSkaterStats] {
        allAvailableSkaters.filter {
            $0.position == "D"
        }
    }

    public init(fantasyTeam: NHLFantasyTeam, fantasyLeague: NHLFantasyTeamLeague) {
        self.fantasyTeam = fantasyTeam
        self.fantasyLeague = fantasyLeague
    }

    private let skaterCategories = ["Goals", "Assists", "Points"]
    private let goalieCategories = ["Wins", "Save %", "Goals Against Average"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Turn indicator
                    VStack(spacing: 8) {
                        if isProcessingCPUTurn {
                            Text("CPU Turn: \(currentTeam.getName())")
                                .font(.headline)
                                .foregroundColor(.orange)
                                .padding()
                        } else if isHumanTurn {
                            Text("Your Turn!")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding()
                        } else {
                            Text("Waiting for: \(currentTeam.getName())")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding()
                        }
                        
                        Text("Time Remaining: \(timeRemaining)s")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    
                    VStack(spacing: 10) {
                        Text("Skaters: \(skatersCount)/\(maxSkaters) | Forwards: \(forwardsCount)/\(maxForwards) | Defense: \(defensemenCount)/\(maxDefensemen) | Goalies: \(goaliesCount)/\(maxGoalies)")
                            .font(.subheadline)
                            .padding(.bottom, 5)
                            .foregroundColor(.blue)
                        
                        if draftComplete {
                            Text("Draft complete!")
                                .font(.headline)
                                .foregroundColor(.green)
                                .onAppear {
                                    fantasyTeam.setCompletedDraft(true)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                        }
                    }

                    if let last = lastSelectedPlayer {
                        HStack {
                            if let url = URL(string: last.headshot) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                }
                            }

                            VStack(alignment: .leading) {
                                Text("You Drafted:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(last.firstName.def) \(last.lastName.def)")
                                    .font(.headline)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    if let cpuDraft = lastCPUPlayer {
                        HStack {
                            if let url = URL(string: cpuDraft.player.headshot) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                }
                            }

                            VStack(alignment: .leading) {
                                Text("\(cpuDraft.teamName) selected:")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("\(cpuDraft.player.firstName.def) \(cpuDraft.player.lastName.def)")
                                    .font(.headline)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }

                    // Only show player lists when it's human turn
                    if isHumanTurn && !isProcessingCPUTurn {
                        SkaterSectionView(
                            title: "Forwards",
                            selectedCategory: $selectedSkaterCategory,
                            skaters: .constant(availableForwards),
                            isLoading: isSkaterLoading,
                            fantasyTeam: fantasyTeam,
                            statsType: selectedSkaterCategory.lowercased(),
                            removePlayer: { player in
                                allAvailableSkaters.removeAll { $0.playerId == player.playerId }
                            },
                            onPlayerDrafted: {
                                onHumanPlayerDrafted()
                            },
                            setLastSelected: { player in
                                lastSelectedPlayer = player
                            },
                            onDraftCompleted: checkDraftCompletion,
                            onCPUSelection: {
                                // This will be handled by the turn system
                            },
                            canDraftPlayer: canDraftPlayer,
                            onPositionLimitReached: { message in
                                positionLimitMessage = message
                                showPositionLimitAlert = true
                            }
                        )

                        SkaterSectionView(
                            title: "Defensemen",
                            selectedCategory: $selectedSkaterCategory,
                            skaters: .constant(availableDefensemen),
                            isLoading: isSkaterLoading,
                            fantasyTeam: fantasyTeam,
                            statsType: selectedSkaterCategory.lowercased(),
                            removePlayer: { player in
                                allAvailableSkaters.removeAll { $0.playerId == player.playerId }
                            },
                            onPlayerDrafted: {
                                onHumanPlayerDrafted()
                            },
                            setLastSelected: { player in
                                lastSelectedPlayer = player
                            },
                            onDraftCompleted: checkDraftCompletion,
                            onCPUSelection: {
                                // This will be handled by the turn system
                            },
                            canDraftPlayer: canDraftPlayer,
                            onPositionLimitReached: { message in
                                positionLimitMessage = message
                                showPositionLimitAlert = true
                            }
                        )

                        GoalieSectionView(
                            selectedCategory: $selectedGoalieCategory,
                            goalies: $allAvailableGoalies,
                            isLoading: isGoalieLoading,
                            fantasyTeam: fantasyTeam,
                            statsType: selectedGoalieCategory.lowercased(),
                            removePlayer: { player in
                                allAvailableGoalies.removeAll { $0.playerId == player.playerId }
                            },
                            onPlayerDrafted: {
                                onHumanPlayerDrafted()
                            },
                            setLastSelected: { player in
                                lastSelectedPlayer = player
                            },
                            onDraftCompleted: checkDraftCompletion,
                            onCPUSelection: {
                                // This will be handled by the turn system
                            },
                            canDraftPlayer: canDraftPlayer,
                            onPositionLimitReached: { message in
                                positionLimitMessage = message
                                showPositionLimitAlert = true
                            }
                        )
                    } else if !isHumanTurn {
                        // Show waiting message when it's not human turn
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Waiting for other teams to draft...")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(height: 200)
                    }
                    
                    if !lastCPUSelections.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Recent CPU Drafts:")
                                .font(.headline)
                                .padding(.top)

                            ForEach(lastCPUSelections.suffix(5), id: \.player.playerId) { selection in
                                Text("\(selection.teamName) drafted \(selection.player.firstName.def) \(selection.player.lastName.def)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Fantasy Draft")
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            loadInitialData()
            startDraftProcess()
        }
        .onChange(of: selectedSkaterCategory) { newValue in
            statsSkaterType = skaterStatKey(for: newValue)
            isSkaterLoading = true
            decodeAvailableSkaters(season: season, gameType: gameType, statsType: statsSkaterType)
        }
        .onChange(of: selectedGoalieCategory) { newValue in
            statsGoalieType = goalieStatKey(for: newValue)
            isGoalieLoading = true
            decodeAvailableGoalies(season: season, gameType: gameType, statsType: statsGoalieType)
        }
        .onChange(of: currentDraftTurn) { _ in
            processTurn()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showBackConfirmation = true
                    fantasyTeam.clearPlayers()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
        .alert(isPresented: $showBackConfirmation) {
            Alert(
                title: Text("Are you sure you want to go back?"),
                message: Text("Going back will reset your draft progress."),
                primaryButton: .destructive(Text("Leave")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .alert("Position Limit Reached", isPresented: $showPositionLimitAlert) {
            Button("OK") { }
        } message: {
            Text(positionLimitMessage)
        }
    }
    
    // MARK: - Draft Turn Management
    
    
    
    private func onHumanPlayerDrafted() {
        print("Human drafted - advancing turn")
        timer?.invalidate()
        advanceTurn()
    }
    
    
    private func isDraftComplete() -> Bool {
        // Check if the user's team has completed the draft requirements
        let complete = draftComplete
        print("Draft complete check: \(complete)")
        return complete
    }
    
    private func draftSinglePlayerForCPU() {
        let team = currentTeam
        print("CPU team \(team.getName()) attempting to draft a player")
        
        // Get current team composition to make intelligent picks
        let composition = team.getTeamComposition()
        let totalSkaters = composition.forwards + composition.defensemen
        
        // Determine what type of player to draft based on team needs
        var shouldPickGoalie = false
        var preferredPosition = ""
        
        // Priority logic for drafting
        if composition.goalies == 0 {
            // Must have at least one goalie
            shouldPickGoalie = true
        } else if composition.forwards < minForwards {
            // Need more forwards
            preferredPosition = "forward"
        } else if composition.defensemen < minDefensemen {
            // Need more defensemen
            preferredPosition = "defense"
        } else if composition.goalies < maxGoalies && totalSkaters >= maxSkaters {
            // Fill remaining goalie spots if skater positions are full
            shouldPickGoalie = true
        } else if totalSkaters < maxSkaters {
            // Random choice between available positions
            if composition.forwards < maxForwards && composition.defensemen < maxDefensemen {
                preferredPosition = Bool.random(probability: 0.6) ? "forward" : "defense"
            } else if composition.forwards < maxForwards {
                preferredPosition = "forward"
            } else if composition.defensemen < maxDefensemen {
                preferredPosition = "defense"
            }
        } else if composition.goalies < maxGoalies {
            // Only goalie spots left
            shouldPickGoalie = true
        } else {
            print("Team \(team.getName()) appears to be full - skipping")
            return
        }
        
        var selectedPlayer: NHLPlayerSkaterStats? = nil
        
        if shouldPickGoalie {
            // Draft a goalie
            let availableGoalies = allAvailableGoalies.filter { player in
                !fantasyLeague.teams.contains { team in
                    team.hasDrafted(player.playerId ?? -1)
                }
            }
            
            selectedPlayer = availableGoalies.first
            print("CPU team \(team.getName()) looking for goalie, found: \(selectedPlayer?.firstName.def ?? "none") \(selectedPlayer?.lastName.def ?? "")")
        } else {
            // Draft a skater
            var availablePlayers: [NHLPlayerSkaterStats] = []
            
            if preferredPosition == "forward" {
                availablePlayers = allAvailableSkaters.filter { player in
                    ["F", "C", "L", "R"].contains(player.position) &&
                    !fantasyLeague.teams.contains { team in
                        team.hasDrafted(player.playerId ?? -1)
                    }
                }
            } else if preferredPosition == "defense" {
                availablePlayers = allAvailableSkaters.filter { player in
                    player.position == "D" &&
                    !fantasyLeague.teams.contains { team in
                        team.hasDrafted(player.playerId ?? -1)
                    }
                }
            } else {
                // Any skater
                availablePlayers = allAvailableSkaters.filter { player in
                    player.position != "G" &&
                    !fantasyLeague.teams.contains { team in
                        team.hasDrafted(player.playerId ?? -1)
                    }
                }
            }
            
            selectedPlayer = availablePlayers.first
            print("CPU team \(team.getName()) looking for \(preferredPosition), found: \(selectedPlayer?.firstName.def ?? "none") \(selectedPlayer?.lastName.def ?? "")")
        }
        
        // Draft the selected player
        if let player = selectedPlayer {
            team.addPlayer(player)
            print("Team \(team.getName()) successfully drafted \(player.firstName.def) \(player.lastName.def) (\(player.position))")
            
            // Remove from available lists
            allAvailableSkaters.removeAll { $0.playerId == player.playerId }
            allAvailableGoalies.removeAll { $0.playerId == player.playerId }
            
            // Update UI
            DispatchQueue.main.async {
                self.lastCPUPlayer = (team.getName(), player)
                self.lastCPUSelections.append((team.getName(), player))
                
                // Keep only last 10 selections
                if self.lastCPUSelections.count > 10 {
                    self.lastCPUSelections.removeFirst()
                }
            }
        } else {
            print("No available players for team \(team.getName()) to draft")
        }
    }

    // Also update the processTurn method to handle completed teams better:
    private func processTurn() {
        print("Processing turn \(currentDraftTurn), team: \(currentTeam.getName()), isHuman: \(isHumanTurn)")
        
        // Check if the human player has completed their draft (main completion condition)
        if isHumanTurn && isDraftComplete() {
            print("Human player draft complete!")
            checkDraftCompletion()
            return
        }
        
        if isHumanTurn {
            print("Human turn - starting timer")
            // Human player's turn - start timer
            startTimer()
        } else if !isProcessingCPUTurn {
            print("CPU turn - processing for \(currentTeam.getName())")
            // CPU turn - process automatically after a brief delay
            isProcessingCPUTurn = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.draftSinglePlayerForCPU()
                self.advanceTurn()
            }
        }
    }

    // Update the startDraftProcess method:
    private func startDraftProcess() {
        // Reset turn counter and start from 0 (first team)
        currentDraftTurn = 0
        print("Starting draft process with turn \(currentDraftTurn)")
        processTurn()
    }

    // Fix the advanceTurn method with better logging:
    private func advanceTurn() {
        let oldTurn = currentDraftTurn
        let oldTeam = currentTeam.getName()
        
        // Move to next team
        currentDraftTurn = (currentDraftTurn + 1) % fantasyLeague.teams.count
        isProcessingCPUTurn = false
        
        let newTeam = currentTeam.getName()
        print("Advanced from turn \(oldTurn) (\(oldTeam)) to turn \(currentDraftTurn) (\(newTeam))")
        
        // Process next turn
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.processTurn()
        }
    }

    

    // MARK: - Existing Methods (API calls, etc.)
    
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
                let result = try decoder.decode(NHLStatsLeadersAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    availableSkaters = result
                    let apiSkaters = getSkatersList(from: result, for: statsSkaterType)
                    let convertedSkaters = apiSkaters.map { $0.toNHLPlayerSkaterStats() }
                    
                    // Filter out players drafted by ANY team in the league
                    allAvailableSkaters = convertedSkaters.filter { player in
                        !fantasyLeague.teams.contains { team in
                            team.hasDrafted(player.playerId ?? -1)
                        }
                    }
                    isSkaterLoading = false
                }
            } catch {
                print("Error decoding skaters: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString.prefix(1000))")
                }
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
                let result = try decoder.decode(NHLGoalieStatsLeadersAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    availableGoalies = result
                    let apiGoalies = getGoalieList(from: result, for: statsGoalieType)
                    let convertedGoalies = apiGoalies.map { $0.toNHLPlayerSkaterStats() }
                    
                    // Filter out players drafted by ANY team in the league
                    allAvailableGoalies = convertedGoalies.filter { player in
                        !fantasyLeague.teams.contains { team in
                            team.hasDrafted(player.playerId ?? -1)
                        }
                    }
                    isGoalieLoading = false
                }
            } catch {
                print("Error decoding goalies: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString.prefix(1000))")
                }
            }
        }.resume()
    }

    private func getSkatersList(from stats: NHLStatsLeadersAPIResponse, for type: String) -> [NHLPlayerAPIStats] {
        switch type {
        case "goals": return stats.goals ?? []
        case "assists": return stats.assists ?? []
        case "points": return stats.points ?? []
        default: return []
        }
    }

    private func getGoalieList(from stats: NHLGoalieStatsLeadersAPIResponse, for type: String) -> [NHLPlayerAPIStats] {
        switch type {
        case "wins": return stats.wins ?? []
        case "savePctg": return stats.savePctg ?? []
        case "goalsAgainstAverage": return stats.goalsAgainstAverage ?? []
        default: return []
        }
    }

    private func loadInitialData() {
        decodeAvailableSkaters(season: season, gameType: gameType, statsType: statsSkaterType)
        decodeAvailableGoalies(season: season, gameType: gameType, statsType: statsGoalieType)
    }

    private func skaterStatKey(for label: String) -> String {
        switch label {
        case "Goals": return "goals"
        case "Assists": return "assists"
        case "Points": return "points"
        default: return "goals"
        }
    }

    private func goalieStatKey(for label: String) -> String {
        switch label {
        case "Wins": return "wins"
        case "Save %": return "savePctg"
        case "Goals Against Average": return "goalsAgainstAverage"
        default: return "wins"
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timeRemaining = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                autoDraftPlayer()
                advanceTurn()
            }
        }
    }
    
    private func autoDraftPlayer() {
        let shouldPickSkater = Bool.random(probability: 0.8)
        if shouldPickSkater, let skater = allAvailableSkaters.first {
            fantasyTeam.addPlayer(skater)
            allAvailableSkaters.removeAll { $0.playerId == skater.playerId }
            lastSelectedPlayer = skater
        } else if let goalie = allAvailableGoalies.first {
            fantasyTeam.addPlayer(goalie)
            allAvailableGoalies.removeAll { $0.playerId == goalie.playerId }
            lastSelectedPlayer = goalie
        }
    }
    
    private func checkDraftCompletion() {
        if draftComplete {
            timer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Supporting Views

struct PlayerRow: View {
    let player: NHLPlayerSkaterStats
    let statsType: String
    let fantasyTeam: NHLFantasyTeam
    let onPlayerSelected: () -> Void
    let onAfterSelection: () -> Void
    let onDraftCompleted: () -> Void
    let onCPUSelection: () -> Void
    let setLastSelected: (NHLPlayerSkaterStats) -> Void
    let canDraftPlayer: (NHLPlayerSkaterStats) -> Bool
    let onPositionLimitReached: (String) -> Void
    let getPositionLimitMessage: (NHLPlayerSkaterStats) -> String

    var trimmedString: String {
        String(format: "%g", player.value)
    }

    var body: some View {
        Button(action: {
            if canDraftPlayer(player) {
                fantasyTeam.addPlayer(player)
                onPlayerSelected()
                setLastSelected(player)
                onAfterSelection()
                onDraftCompleted()
            } else {
                let message = getPositionLimitMessage(player)
                onPositionLimitReached(message)
            }
        }) {
            HStack {
                Text("\(player.firstName.def) \(player.lastName.def)")
                Spacer()
                Text("\(trimmedString) \(statsType)")
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SkaterSectionView: View {
    let title: String
    @Binding var selectedCategory: String
    @Binding var skaters: [NHLPlayerSkaterStats]
    let isLoading: Bool
    let fantasyTeam: NHLFantasyTeam
    let statsType: String
    let removePlayer: (NHLPlayerSkaterStats) -> Void
    let onPlayerDrafted: () -> Void
    let setLastSelected: (NHLPlayerSkaterStats) -> Void
    let onDraftCompleted: () -> Void
    let onCPUSelection: () -> Void
    let canDraftPlayer: (NHLPlayerSkaterStats) -> Bool
    let onPositionLimitReached: (String) -> Void

    var body: some View {
        Section(header: Text("\(title)")) {
            Picker("Category", selection: $selectedCategory) {
                ForEach(["Goals", "Assists", "Points"], id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(SegmentedPickerStyle())

            if isLoading {
                ProgressView("Loading...")
            } else {
                List(skaters, id: \.playerId) { player in
                    PlayerRow(
                        player: player,
                        statsType: statsType,
                        fantasyTeam: fantasyTeam,
                        onPlayerSelected: {
                            removePlayer(player)
                        },
                        onAfterSelection: {
                            onPlayerDrafted()
                        },
                        onDraftCompleted: {
                            onDraftCompleted()
                        },
                        onCPUSelection: {
                            onCPUSelection()
                        },
                        setLastSelected: { player in
                            setLastSelected(player)
                        },
                        canDraftPlayer: canDraftPlayer,
                        onPositionLimitReached: onPositionLimitReached,
                        getPositionLimitMessage: { player in
                            if player.position == "D" {
                                if fantasyTeam.draftedPlayers.filter({ $0.position == "D" }).count >= 11 {
                                    return "You've reached the maximum number of defensemen (11). You cannot draft any more defensemen."
                                } else if fantasyTeam.draftedPlayers.filter({ $0.position != "G" }).count >= 23 {
                                    return "You've reached the maximum number of skaters (23). You cannot draft any more skaters."
                                }
                            } else if ["F", "C", "L", "R"].contains(player.position) {
                                if fantasyTeam.draftedPlayers.filter({ ["F", "C", "L", "R"].contains($0.position) }).count >= 17 {
                                    return "You've reached the maximum number of forwards (17). You cannot draft any more forwards."
                                } else if fantasyTeam.draftedPlayers.filter({ $0.position != "G" }).count >= 23 {
                                    return "You've reached the maximum number of skaters (23). You cannot draft any more skaters."
                                }
                            }
                            return "You cannot draft this player."
                        }
                    )
                }
                .frame(height: 300)
            }
        }
    }
}

struct GoalieSectionView: View {
    @Binding var selectedCategory: String
    @Binding var goalies: [NHLPlayerSkaterStats]
    let isLoading: Bool
    let fantasyTeam: NHLFantasyTeam
    let statsType: String
    let removePlayer: (NHLPlayerSkaterStats) -> Void
    let onPlayerDrafted: () -> Void
    let setLastSelected: (NHLPlayerSkaterStats) -> Void
    let onDraftCompleted: () -> Void
    let onCPUSelection: () -> Void
    let canDraftPlayer: (NHLPlayerSkaterStats) -> Bool
    let onPositionLimitReached: (String) -> Void

    var body: some View {
        Section(header: Text("Goalies")) {
            Picker("Category", selection: $selectedCategory) {
                ForEach(["Wins", "Save %", "Goals Against Average"], id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(SegmentedPickerStyle())

            if isLoading {
                ProgressView("Loading...")
            } else {
                List(goalies, id: \.playerId) { player in
                    PlayerRow(
                        player: player,
                        statsType: statsType,
                        fantasyTeam: fantasyTeam,
                        onPlayerSelected: {
                            removePlayer(player)
                        },
                        onAfterSelection: {
                            onPlayerDrafted()
                        },
                        onDraftCompleted: {
                            onDraftCompleted()
                        },
                        onCPUSelection: {
                            onCPUSelection()
                        },
                        setLastSelected: {_ in
                            setLastSelected(player)
                        },
                        canDraftPlayer: canDraftPlayer,
                        onPositionLimitReached: onPositionLimitReached,
                        getPositionLimitMessage: { player in
                            if player.position == "G" {
                                return "You've reached the maximum number of goalies (3). You cannot draft any more goalies."
                            }
                            return "You cannot draft this player."
                        }
                    )
                }
                .frame(height: 300)
            }
        }
    }
}

extension Bool {
    static func random(probability: Double) -> Bool {
        return Double.random(in: 0..<1) < probability
    }
}
