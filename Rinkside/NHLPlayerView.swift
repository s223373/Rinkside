//
//  NHLPlayerView.swift
//  Rinkside
//
//  Created by Nik Bar on 12/28/24.
//
import SwiftUI

struct NHLPlayerView: View {
    @State private var playerInfo: NHLPlayer?
    @State private var showingCompareSheet = false
    @State private var compareName = ""
    @State private var navigateToCompare = false
    @State private var secondPlayerId: Int?
    
    var playerRating: Int? {
        guard let player = playerInfo,
              let latestSeason = player.seasonTotals?
                .filter({ $0.gameTypeId == 2 })
                .sorted(by: { ($0.season ?? 0) > ($1.season ?? 0) })
                .first else {
            return nil
        }
        
        let raw = PlayerRatingEngine.calculateRawSkaterScore(for: latestSeason)
        
        // Temporary scaling using default mean and std dev (you could make this dynamic later)
        return PlayerRatingEngine.scaleToRating(rawScore: raw, mean: 60, stdDev: 10)
    }

    private let playerId: Int
    
    private let gridItems = Array(repeating: GridItem(.fixed(120), spacing: 0), count: 10)
    
    init(playerId: Int) {
        self.playerId = playerId
    }
    
    var body: some View {
        ScrollView {
            NavigationLink(
                destination: NHLPlayerCompareView(player1Id: playerId, player2Id: secondPlayerId ?? 0),
                isActive: $navigateToCompare
            ) {
                EmptyView()
            }
            .hidden()
            if let player = playerInfo {
                VStack(spacing: 20) {
                    PlayerHeaderView(player: player, rating: playerRating)
                    PlayerDetailsView(player: player)
                    PlayerStatsView(player: player)
                }
                .padding()
            }else {
                ProgressView("Loading player...")
                    .onAppear {
                        decodePlayer(playerId: playerId)
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Compare Stats") {
                    showingCompareSheet = true
                }
            }
        }
        .sheet(isPresented: $showingCompareSheet) {
            CompareStatsSheet(compareName: $compareName) { name in
                searchPlayerByName(name: name)
            }
        }

    }
    
    func decodePlayer(playerId: Int) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let url = NHLResource.basePlayerLandingURL(for: playerId) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                do {
                    playerInfo = try decoder.decode(NHLPlayer.self, from: data)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func searchPlayerByName(name: String) {
        let baseUrl = "https://suggest.svc.nhl.com/svc/suggest/v1/minplayers/"
        let query = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseUrl)\(query)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let suggestions = json?["suggestions"] as? [[String: Any]],
                   let firstSuggestion = suggestions.first,
                   let playerId = firstSuggestion["id"] as? Int {
                    DispatchQueue.main.async {
                        self.secondPlayerId = playerId
                        self.navigateToCompare = true
                    }
                } else {
                    print("Player not found.")
                }
            } catch {
                print("Failed to parse search: \(error)")
            }
        }.resume()
    }

    
}

struct PlayerHeaderView: View {
    let player: NHLPlayer
    let rating: Int?
    
    var body: some View {
        VStack {
            ZStack {
                AsyncImage(url: URL(string: player.heroImage)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 300)
                        .opacity(0.3)
                } placeholder: {
                    Color.gray.opacity(0.1).frame(maxWidth: .infinity, maxHeight: 300)
                }
                
                ZStack(alignment: .bottomTrailing) {
                    AsyncImage(url: URL(string: player.headshot)) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 4))
                            .shadow(radius: 10)
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 150)
                            .overlay(ProgressView())
                    }
                    
                    if let rating = rating {
                        RatingCircleView(rating: rating)
                            .offset(x: 8, y: 8) // a little padding outside the headshot circle
                    }
                }
                .frame(width: 150, height: 150)
            }
            
            VStack(alignment: .center, spacing: 8) {
                Text("\(player.firstName.def) \(player.lastName.def)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(player.fullTeamName?.def ?? "N/A")
                    .font(.title3)
                    .foregroundColor(.secondary)
                HStack(spacing: 15) {
                    Text("#\(player.sweaterNumber ?? -1)")
                        .font(.title2).bold().foregroundColor(.blue)
                    Text(player.position)
                        .font(.title2).bold().foregroundColor(.orange)
                }
            }
        }
    }
}

struct RatingCircleView: View {
    var rating: Int
    
    private var progress: Double {
        Double(rating) / 100.0
    }
    
    var body: some View {
        ZStack {
            // Solid white background circle
            Circle()
                .fill(Color.white)
                .frame(width: 40, height: 40)

            // Gray track ring
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                .frame(width: 40, height: 40)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 40, height: 40)
                .animation(.easeOut(duration: 0.5), value: progress)

            // Rating number in center
            Text("\(rating)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
    }
}


struct PlayerDetailsView: View {
    let player: NHLPlayer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Player Details").font(.title2).fontWeight(.semibold)
            DetailRow(label: "Born:", value: formatDate(player.birthDate ?? "2001-01-01"))
            DetailRow(label: "Age:", value: "\(calculateAge(from: player.birthDate ?? "2001-01-01") ?? 0) years old")
            DetailRow(label: "Height:", value: getHeight(from: player.heightInInches))
            DetailRow(label: "Weight:", value: "\(player.weightInPounds) lbs")
            
            if let draft = player.draftDetails {
                Text("Drafted: \(draft.overallPick)\(daySuffix(num: draft.overallPick)) overall by \(draft.teamAbbrev) in \(removeCommas(from: "\(draft.year)")) (\(draft.round)\(daySuffix(num: draft.round)) round, \(draft.pickInRound)\(daySuffix(num: draft.pickInRound)) pick)")
                    .padding(.top)
            } else {
                Text("Undrafted").italic().foregroundColor(.gray).padding(.top)
            }
        }
        .padding().background(Color(.systemGray6)).cornerRadius(12)
    }
}

struct PlayerStatsView: View {
    let player: NHLPlayer

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Season Stats")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 5)

            if let seasonTotals = player.seasonTotals, !seasonTotals.isEmpty {
                ForEach(seasonTotals, id: \.gameTypeId) { season in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Season: \(formatSeason(season.season))")
                            .font(.headline)
                        Text("Team: \(season.teamName?.def ?? "N/A")")
                        Text("League: \(season.leagueAbbrev ?? "N/A")")
                        Text("Games Played: \(season.gamesPlayed ?? 0)")
                        Text("Goals: \(season.goals ?? 0)")
                        Text("Assists: \(season.assists ?? 0)")
                        Text("Points: \(season.points ?? 0)")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            } else {
                Text("No stats available")
                    .italic()
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label).fontWeight(.medium)
            Text(value)
        }
    }
}

struct TableHeader: View {
    let columns: [String]
    var body: some View {
        HStack {
            ForEach(columns, id: \ .self) { column in
                Text(column).fontWeight(.bold).frame(minWidth: 120)
            }
        }
        .padding().background(Color.gray.opacity(0.2))
    }
}

struct TableRow: View {
    let values: [String]
    var body: some View {
        HStack {
            ForEach(values, id: \ .self) { value in
                Text(value).frame(minWidth: 120)
            }
        }
        .padding(.vertical, 5).background(Color.white).cornerRadius(8)
    }
}

struct CompareStatsSheet: View {
    @Binding var compareName: String
    var onSearch: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter another NHL player's name:")
                    .font(.headline)
                
                TextField("e.g. Sidney Crosby", text: $compareName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    onSearch(compareName)
                }) {
                    Text("Search and Compare")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Compare Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

    
    func calculateAge(from dateString: String, with format: String = "yyyy-MM-dd") -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        guard let birthDate = dateFormatter.date(from: dateString) else {
            print("Invalid date string")
            return nil
        }
        
        let calendar = Calendar.current
        let currentDate = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: currentDate)
        
        return ageComponents.year
    }
    
    func getHeight(from heightInInches: Int) -> String {
        return "\(heightInInches / 12)' \(heightInInches % 12)"
    }
    
    private func daySuffix(num: Int) -> String {
        switch num % 10 {
        case 1 where num % 100 != 11: return "st"
        case 2 where num % 100 != 12: return "nd"
        case 3 where num % 100 != 13: return "rd"
        default: return "th"
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString) else { return dateString }
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
    
    private func nonGoalieRow(for season: NHLSeasonTotal) -> some View {
        TableRow(values: ["\(season.season ?? -1)", season.teamName?.def ?? "N/A", season.leagueAbbrev ?? "N/A", "\(season.gamesPlayed ?? -1)", "\(season.goals ?? -1)", "\(season.assists ?? -1)", "\(season.points ?? -1)", "\(season.plusMinus ?? -1)", "\(season.pim ?? -1)"])
    }
    
    private func goalieRow(for season: NHLSeasonTotal) -> some View {
        TableRow(values: ["\(season.season ?? -1)", season.teamName?.def ?? "N/A", season.leagueAbbrev ?? "N/A", "\(season.gamesPlayed ?? -1)", "\(season.gamesStarted ?? -1)", "\(season.goalsAgainstAvg ?? -1)", "\(season.savePctg ?? -1)", "\(season.shutouts ?? -1)", "\(season.goals ?? -1)", "\(season.assists ?? -1)"])
    }

    func removeCommas(from numberString: String) -> String {
        return numberString.replacingOccurrences(of: ",", with: "")
    }

func formatSeason(_ seasonInt: Int?) -> String {
    guard let seasonInt = seasonInt else { return "N/A" }
    let seasonStr = String(seasonInt)
    guard seasonStr.count == 8 else { return seasonStr }
    
    let startYear = seasonStr.prefix(4)
    let endYear = seasonStr.suffix(4)
    return "\(startYear)-\(endYear)"
}






