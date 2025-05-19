//
//  NHLFantasyDraftView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/19/25.
//
import SwiftUI

struct NHLFantasyDraftView: View {
    
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
    
    private var fantasyTeam: NHLFantasyTeam
    
    public init(fantasyTeam: NHLFantasyTeam) {
        self.fantasyTeam = fantasyTeam
    }
    
    
    private let skaterCategories = ["Goals", "Assists", "Points"]
    private let goalieCategories = ["Wins", "Save %", "Goals Against Average"]
    
    var body: some View {
        NavigationView {
            VStack {
                Section(header: Text("Players")) {
                    Picker("Category", selection: $selectedSkaterCategory) {
                        ForEach(skaterCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    if isSkaterLoading {
                        ProgressView("Loading...")
                    } else {
                        if (selectedSkaterCategory == "Goals") {
                            Section(header: Text("Goal Leaders")) {
                                List {
                                    ForEach(availableSkaters?.goals ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "goals", fantasyTeam: fantasyTeam)
                                    }
                                }
                            }
                        } else if (selectedSkaterCategory == "Assists") {
                            Section(header: Text("Assist Leaders")) {
                                List {
                                    ForEach(availableSkaters?.assists ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "assists", fantasyTeam: fantasyTeam)
                                    }
                                }
                            }
                        } else {
                            Section(header: Text("Point Leaders")) {
                                List {
                                    ForEach(availableSkaters?.points ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "points", fantasyTeam: fantasyTeam)
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
                Section(header: Text("Goalies")) {
                    Picker("Category", selection: $selectedGoalieCategory) {
                        ForEach(goalieCategories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    if isGoalieLoading {
                        ProgressView("Loading...")
                    } else {
                        if (selectedGoalieCategory == "Wins") {
                            Section(header: Text("Wins Leaders")) {
                                List {
                                    ForEach(availableGoalies?.wins ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "wins", fantasyTeam: fantasyTeam)
                                    }
                                }
                            }
                        } else if (selectedGoalieCategory == "Save %") {
                            Section(header: Text("Save % Leaders")) {
                                List {
                                    ForEach(availableGoalies?.savePctg ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "", fantasyTeam: fantasyTeam)
                                    }
                                }
                            }
                        } else {
                            Section(header: Text("Goals Against Average Leaders")) {
                                List {
                                    ForEach(availableGoalies?.goalsAgainstAverage ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "GAA", fantasyTeam: fantasyTeam)
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
            }
        } .onAppear() {
            decodeAvailableSkaters(season: season, gameType: gameType, statsType: statsSkaterType)
            decodeAvailableGoalies(season: season, gameType: gameType, statsType: statsGoalieType)
        } .onChange(of: selectedSkaterCategory) { newValue in
            switch newValue {
            case "Goals":
                statsSkaterType = "goals"
            case "Assists":
                statsSkaterType = "assists"
            case "Points":
                statsSkaterType = "points"
            default:
                statsSkaterType = "goals"
            }
            isSkaterLoading = true
            decodeAvailableSkaters(season: season, gameType: gameType, statsType: statsSkaterType)
        } .onChange(of: selectedGoalieCategory) { newValue in
            switch newValue {
            case "Wins":
                statsSkaterType = "wins"
            case "Save %":
                statsSkaterType = "savePctg"
            case "Goals Against Average":
                statsSkaterType = "goalsAgainstAverage"
            default:
                statsSkaterType = "wins"
            }
            isGoalieLoading = true
            decodeAvailableGoalies(season: season, gameType: gameType, statsType: statsSkaterType)
        }
    }
        
        func decodeAvailableSkaters(season: String, gameType: Int, statsType: String) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let url = NHLResource.skaterStatsLeadersURL(season: season, gameType: gameType, statsType: statsType) else {
                print("Cannot create available players stats URL for \(season)")
                return
            }
            print("Loading players stats leaders for \(season) with URL \(url.absoluteString)")
            
            let dataTask = URLSession.shared.dataTask(with: url) { dataW, response, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let dataL = dataW else {
                    print("No data received")
                    return
                }
                
                do {
                    let result = try decoder.decode(NHLPlayerSkaterStatsLeaders.self, from: dataL)
                    DispatchQueue.main.async {
                        availableSkaters = result
                        isSkaterLoading = false
                    }
                } catch {
                    print(error)
                }
            }
            dataTask.resume()
        }
        
        func decodeAvailableGoalies(season: String, gameType: Int, statsType: String) {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            guard let url = NHLResource.goalieStatsLeadersURL(season: season, gameType: gameType, statsType: statsType) else {
                print("Cannot create available goalies stats URL for \(season)")
                return
            }
            print("Loading goalie stats leaders for \(season) with URL \(url.absoluteString)")
            
            let dataTask = URLSession.shared.dataTask(with: url) { dataW, response, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let dataL = dataW else {
                    print("No data received")
                    return
                }
                
                do {
                    let result = try decoder.decode(NHLPlayerGoalieStatsLeaders.self, from: dataL)
                    DispatchQueue.main.async {
                        availableGoalies = result
                        isGoalieLoading = false
                    }
                } catch {
                    print(error)
                }
            }
            dataTask.resume()
        }
        
        struct playerRow: View {
            let player: NHLPlayerSkaterStats
            let statsType: String
            let fantasyTeam: NHLFantasyTeam
            
            
            var trimmedString: String {
                String(format: "%g", player.value)
            }
            
            var body: some View {
                Button(action: {
                    fantasyTeam.addPlayer(player)
                    print("Player row tapped: \(player.firstName.def) \(player.lastName.def)")
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
        
    }
