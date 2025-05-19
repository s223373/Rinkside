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
    @State private var isLoading: Bool = true
    @State private var selectedSkaterCategory: String = "Goals"
    @State private var selectedGoalieCategory: String = "Wins"
    
    @State private var season: String = "20242025"
    @State private var gameType: Int = 2
    @State private var statsSkaterType: String = "goals"
    @State private var statsGoalieType: String = "wins"
    
    
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
                    if isLoading {
                        ProgressView("Loading...")
                    } else {
                        if (selectedSkaterCategory == "Goals") {
                            Section(header: Text("Goal Leaders")) {
                                List {
                                    ForEach(availableSkaters?.goals ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "goals")
                                    }
                                }
                            }
                        } else if (selectedSkaterCategory == "Assists") {
                            Section(header: Text("Assist Leaders")) {
                                List {
                                    ForEach(availableSkaters?.assists ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "assists")
                                    }
                                }
                            }
                        } else {
                            Section(header: Text("Point Leaders")) {
                                List {
                                    ForEach(availableSkaters?.points ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "points")
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
                    if isLoading {
                        ProgressView("Loading...")
                    } else {
                        if (selectedGoalieCategory == "Wins") {
                            Section(header: Text("Wins Leaders")) {
                                List {
                                    ForEach(availableGoalies?.wins ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "wins")
                                    }
                                }
                            }
                        } else if (selectedGoalieCategory == "Save %") {
                            Section(header: Text("Save % Leaders")) {
                                List {
                                    ForEach(availableGoalies?.savePctg ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "")
                                    }
                                }
                            }
                        } else {
                            Section(header: Text("Goals Against Average Leaders")) {
                                List {
                                    ForEach(availableGoalies?.goalsAgainstAverage ?? [], id: \.id) { player in
                                        playerRow(player: player, statsType: "GAA")
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
            }
        } .onAppear() {
            decodeAvailableSkaters(season: season, gameType: gameType, statsType: statsSkaterType)
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
            isLoading = true
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
            isLoading = true
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
            print("Loading roster for \(season) with URL \(url.absoluteString)")
            
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
                        isLoading = false
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
                print("Cannot create available players stats URL for \(season)")
                return
            }
            print("Loading roster for \(season) with URL \(url.absoluteString)")
            
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
                        isLoading = false
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
            var body: some View {
                HStack {
                    Text("\(player.firstName.def) \(player.lastName.def)")
                    Spacer()
                    Text("\(player.value) \(statsType)")
                }
            }
        }
        
    }
