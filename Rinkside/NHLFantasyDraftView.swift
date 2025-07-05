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

    @State private var availableSkaters: NHLPlayerSkaterStatsLeaders?
    @State private var availableGoalies: NHLPlayerGoalieStatsLeaders?
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



    private var fantasyTeam: NHLFantasyTeam
    private var fantasyLeague: NHLFantasyTeamLeague
    
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
        skatersCount >= 23 &&
        forwardsCount >= 12 &&
        defensemenCount >= 6 &&
        goaliesCount >= 3
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
                    Text("Time Remaining: \(timeRemaining)s")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                    
                    VStack(spacing: 10) {
                        Text("Skaters: \(skatersCount) | Forwards: \(forwardsCount) | Defense: \(defensemenCount) | Goalies: \(goaliesCount)")
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
                                Text("Last Drafted:")
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
                            startTimer()
                        },
                        setLastSelected: { player in
                            lastSelectedPlayer = player
                        }, onDraftCompleted: checkDraftCompletion,
                        onCPUSelection: {
                            draftForOtherTeams()
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
                            startTimer()
                        },
                        setLastSelected: { player in
                            lastSelectedPlayer = player
                        }, onDraftCompleted: checkDraftCompletion,
                        onCPUSelection: {
                            draftForOtherTeams()
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
                            startTimer()
                        },
                        setLastSelected: { player in
                            lastSelectedPlayer = player
                        }, onDraftCompleted: checkDraftCompletion,
                        onCPUSelection: {
                            draftForOtherTeams()
                        }
                    )
                    
                    if !lastCPUSelections.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CPU Drafted Players:")
                                .font(.headline)
                                .padding(.top)

                            ForEach(lastCPUSelections, id: \.player.playerId) { selection in
                                Text("\(selection.teamName) drafted \(selection.player.firstName.def) \(selection.player.lastName.def)")
                                    .font(.subheadline)
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
            startTimer()
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
        }.toolbar {
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
    }
    
    private func draftForOtherTeams() {
        for team in fantasyLeague.teams {
            guard team.id != fantasyTeam.id else { continue }

            let shouldPickSkater = Bool.random(probability: 0.8)

            if shouldPickSkater, let randomSkater = allAvailableSkaters.randomElement() {
                team.addPlayer(randomSkater)
                allAvailableSkaters.removeAll { $0.playerId == randomSkater.playerId }
                lastCPUPlayer = (team.getName(), randomSkater)
            } else if let randomGoalie = allAvailableGoalies.randomElement() {
                team.addPlayer(randomGoalie)
                allAvailableGoalies.removeAll { $0.playerId == randomGoalie.playerId }
                lastCPUPlayer = (team.getName(), randomGoalie)
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
                    allAvailableSkaters = getSkatersList(from: result, for: statsSkaterType)
                        .filter { !fantasyTeam.hasDrafted($0.playerId) }
                    isSkaterLoading = false
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
                    allAvailableGoalies = getGoalieList(from: result, for: statsGoalieType)
                        .filter { !fantasyTeam.hasDrafted($0.playerId) }
                    isGoalieLoading = false
                }
            } catch {
                print(error)
            }
        }.resume()
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
                startTimer()
            }
        }
    }
    
    private func autoDraftPlayer() {
        let shouldPickSkater = Bool.random(probability: 0.8)
        if shouldPickSkater, let skater = allAvailableSkaters.first {
            fantasyTeam.addPlayer(skater)
            allAvailableSkaters.removeAll { $0.playerId == skater.playerId }
        } else if let goalie = allAvailableGoalies.first {
            fantasyTeam.addPlayer(goalie)
            allAvailableGoalies.removeAll { $0.playerId == goalie.playerId }
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

    var trimmedString: String {
        String(format: "%g", player.value)
    }

    var body: some View {
        Button(action: {
            fantasyTeam.addPlayer(player)
            onPlayerSelected()
            setLastSelected(player)
            onAfterSelection()
            onCPUSelection()
            onDraftCompleted()
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
                        }
                    )                }
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

