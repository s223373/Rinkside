//
//  NHLClubStatsView.swift
//  Rinkside
//
//  Created by Nik Bar on 4/9/25.
//
import SwiftUI

struct NHLClubStatsView: View {
    @State private var clubStats: NHLClubStats?
    @State private var selectedSkaterCategory = "Points"
    @State private var selectedGoalieCategory = "Wins"
    
    
    
    private let teamId: String
    
    private let skaterCategories = ["Points", "Goals", "Assists"]
    private let goalieCategories = ["Goals Against Average", "Save Percentage", "Wins"]
    
    public init(teamId: String) {
        self.teamId = teamId
    }
    
    var body: some View {
        VStack {
            if let stats = clubStats {
                Form {
                    Section {
                        Picker("Skater Category", selection: $selectedSkaterCategory) {
                            ForEach(skaterCategories, id: \.self) { category in
                                Text(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        ForEach(sortedSkaters(stats.skaters), id: \.id) { skater in
                            NavigationLink(destination: NHLPlayerView(playerId: skater.playerId)) {
                                HStack {
                                    AsyncImage(url: URL(string: skater.headshot)) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 40, height: 40)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("\(skater.firstName) \(skater.lastName)")
                                            .font(.body)
                                        Text(statText(for: skater))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }

                    } header: {
                        Text("Skaters")
                    }

                    Section {
                        Picker("Goalie Category", selection: $selectedGoalieCategory) {
                            ForEach(goalieCategories, id: \.self) { category in
                                Text(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        ForEach(sortedGoalies(stats.goalies), id: \.id) { goalie in
                            NavigationLink(destination: NHLPlayerView(playerId: goalie.playerId)) {
                                HStack {
                                    AsyncImage(url: URL(string: goalie.headshot)) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 40, height: 40)
                                    }

                                    VStack(alignment: .leading) {
                                        Text("\(goalie.firstName) \(goalie.lastName)")
                                            .font(.body)
                                        Text(statText(for: goalie))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }

                    } header: {
                        Text("Goalies")
                    }
                }
            } else {
                ProgressView("Loading team stats...")
                    .onAppear {
                        decodeRegularSeasonTeamStats()
                    }
            }
        }
        .navigationTitle("Team Stats")
    }
    
    func sortedSkaters(_ skaters: [NHLClubSkaterStats]) -> [NHLClubSkaterStats] {
        switch selectedSkaterCategory {
        case "Goals":
            return skaters.sorted { ($0.goals ?? 0) > ($1.goals ?? 0) }
        case "Assists":
            return skaters.sorted { ($0.assists ?? 0) > ($1.assists ?? 0) }
        default:
            return skaters.sorted { ($0.points ?? 0) > ($1.points ?? 0) }
        }
    }
    
    func sortedGoalies(_ goalies: [NHLClubGoalieStats]) -> [NHLClubGoalieStats] {
        switch selectedGoalieCategory {
        case "Save Percentage":
            return goalies.sorted { ($0.savePercentage ?? 0) > ($1.savePercentage ?? 0) }
        case "Goals Against Average":
            return goalies.sorted { ($0.goalsAgainstAverage ?? 99) < ($1.goalsAgainstAverage ?? 99) } // lower is better
        default:
            return goalies.sorted { ($0.wins ?? 0) > ($1.wins ?? 0) }
        }
    }

    func statText(for skater: NHLClubSkaterStats) -> String {
        switch selectedSkaterCategory {
        case "Goals": return "Goals: \(skater.goals ?? 0), Games Played: \(skater.gamesPlayed ?? 0)"
        case "Assists": return "Assists: \(skater.assists ?? 0), Games Played: \(skater.gamesPlayed ?? 0)"
        default: return "Points: \(skater.points ?? 0), Games Played: \(skater.gamesPlayed ?? 0)"
        }
    }

    func statText(for goalie: NHLClubGoalieStats) -> String {
        switch selectedGoalieCategory {
        case "Goals Against Average": return "GAA: \(String(format: "%.2f", goalie.goalsAgainstAverage ?? 0)), Games Played: \(goalie.gamesPlayed ?? 0)"
        case "Save Percentage": return "SV%: \(String(format: "%.3f", goalie.savePercentage ?? 0)), Games Played: \(goalie.gamesPlayed ?? 0)"
        default: return "Wins: \(goalie.wins ?? 0), Games Played: \(goalie.gamesPlayed ?? 0)"
        }
    }

    func decodeRegularSeasonTeamStats() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let url = NHLResource.regularSeasonClubStatsURL(for: teamId) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching stats: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let result = try decoder.decode(NHLClubStats.self, from: data)
                DispatchQueue.main.async {
                    self.clubStats = result
                }
            } catch {
                print("Failed to decode: \(error)")
            }
        }.resume()
    }
}
