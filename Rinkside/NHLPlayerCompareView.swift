//
//  NHLPlayerCompareView.swift
//  Rinkside
//
//  Created by Nik Bar on 4/6/25.
//
//
//  NHLPlayerCompareView.swift
//  Rinkside
//
//  Created by Nik Bar on 4/6/25.
//
import SwiftUI

struct NHLPlayerCompareView: View {
    let player1Id: Int
    let player2Id: Int
    
    @State private var player1Info: NHLPlayer?
    @State private var player2Info: NHLPlayer?

    var body: some View {
        ScrollView {
            if let p1 = player1Info, let p2 = player2Info {
                let p1Playoffs = mostRecentSeason(p1.seasonTotals, gameTypeId: 3)
                let p2Playoffs = mostRecentSeason(p2.seasonTotals, gameTypeId: 3)
                
                let samePlayoffSeason = p1Playoffs?.season == p2Playoffs?.season && p1Playoffs != nil && p2Playoffs != nil
                
                let p1Regular = mostRecentSeason(p1.seasonTotals, gameTypeId: 2)
                let p2Regular = mostRecentSeason(p2.seasonTotals, gameTypeId: 2)

                let season1 = samePlayoffSeason ? p1Playoffs : p1Regular
                let season2 = samePlayoffSeason ? p2Playoffs : p2Regular
                let isPlayoffs = samePlayoffSeason

                VStack(spacing: 32) {
                    // Header with VS indicator
                    headerView()
                    
                    // Player comparison cards
                    playerComparisonCards(p1: p1, p2: p2, season1: season1, season2: season2, isPlayoffs: isPlayoffs)
                    
                    // Stats comparison section
                    if let s1 = season1, let s2 = season2 {
                        statsComparisonSection(season1: s1, season2: s2, isPlayoffs: isPlayoffs)
                    }
                }
                .padding(.top, 20)
            } else {
                loadingView()
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            decodePlayer(playerId: player1Id, p1Flag: true)
            decodePlayer(playerId: player2Id, p1Flag: false)
        }
    }
    
    private func headerView() -> some View {
        VStack(spacing: 12) {
            Text("Player Comparison")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            HStack {
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.blue)
                
                Text("VS")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                    )
                
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func playerComparisonCards(p1: NHLPlayer, p2: NHLPlayer, season1: NHLSeasonTotal?, season2: NHLSeasonTotal?, isPlayoffs: Bool) -> some View {
        HStack(spacing: 16) {
            playerCard(for: p1, season: season1, isPlayoffs: isPlayoffs, position: .left)
            playerCard(for: p2, season: season2, isPlayoffs: isPlayoffs, position: .right)
        }
        .padding(.horizontal, 20)
    }
    
    private func playerCard(for player: NHLPlayer, season: NHLSeasonTotal?, isPlayoffs: Bool, position: CardPosition) -> some View {
        let rating = calculateRating(for: season)
        
        return VStack(spacing: 20) {
            // Player photo and basic info
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 120, height: 120)
                    
                    AsyncImage(url: URL(string: player.headshot)) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 3)
                            )
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 110, height: 110)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                VStack(spacing: 4) {
                    Text("\(player.firstName.def) \(player.lastName.def)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text(player.position)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.orange, .red]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                        )
                }
            }
            
            // Rating circle
            if let rating = rating {
                EnhancedRatingCircleView(rating: rating)
            }
            
            // Player details
            VStack(alignment: .leading, spacing: 8) {
                detailRow(icon: "location", title: "Birthplace", value: "\(player.birthCity.def), \(player.birthCountry)")
                detailRow(icon: "ruler", title: "Height", value: getHeight(from: player.heightInInches))
                detailRow(icon: "scalemass", title: "Weight", value: "\(player.weightInPounds) lbs")
                
                if let draft = player.draftDetails {
                    detailRow(icon: "trophy", title: "Draft", value: "\(draft.overallPick)\(daySuffix(num: draft.overallPick)) overall (\(draft.teamAbbrev), \(removeCommas(from: "\(draft.year)")))")
                } else {
                    detailRow(icon: "trophy", title: "Draft", value: "Undrafted")
                }
            }
            .padding(.horizontal, 4)
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            // Latest stats
            if let season = season {
                VStack(alignment: .leading, spacing: 12) {
                    Text(isPlayoffs ? "Latest Playoff Stats" : "Latest Regular Season Stats")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 6) {
                        statRow(title: "League", value: season.leagueAbbrev ?? "N/A")
                        statRow(title: "Team", value: season.teamName?.def ?? "N/A")
                        statRow(title: "Games", value: "\(season.gamesPlayed ?? 0)")
                        statRow(title: "Goals", value: "\(season.goals ?? 0)")
                        statRow(title: "Assists", value: "\(season.assists ?? 0)")
                        statRow(title: "Points", value: "\(season.points ?? 0)")
                    }
                }
            } else {
                Text("No stats available")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func statsComparisonSection(season1: NHLSeasonTotal, season2: NHLSeasonTotal, isPlayoffs: Bool) -> some View {
        VStack(spacing: 20) {
            Text("Head-to-Head Stats")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                comparisonStatRow(title: "Goals", value1: season1.goals ?? 0, value2: season2.goals ?? 0)
                comparisonStatRow(title: "Assists", value1: season1.assists ?? 0, value2: season2.assists ?? 0)
                comparisonStatRow(title: "Points", value1: season1.points ?? 0, value2: season2.points ?? 0)
                comparisonStatRow(title: "Games", value1: season1.gamesPlayed ?? 0, value2: season2.gamesPlayed ?? 0)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .padding(.horizontal, 20)
    }
    
    private func comparisonStatRow(title: String, value1: Int, value2: Int) -> some View {
        HStack {
            Text("\(value1)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(value1 > value2 ? .green : (value1 < value2 ? .red : .primary))
                .frame(width: 60, alignment: .trailing)
            
            Spacer()
            
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(value2)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(value2 > value1 ? .green : (value2 < value1 ? .red : .primary))
                .frame(width: 60, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 16)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
    
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
    
    private func loadingView() -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text("Loading players...")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private enum CardPosition {
        case left, right
    }

    private func decodePlayer(playerId: Int, p1Flag: Bool) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let url = NHLResource.basePlayerLandingURL(for: playerId) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                do {
                    let decoded = try decoder.decode(NHLPlayer.self, from: data)
                    if p1Flag {
                        player1Info = decoded
                    } else {
                        player2Info = decoded
                    }
                } catch {
                    print("Decoding error for player \(playerId): \(error)")
                }
            }
        }.resume()
    }

    private func mostRecentSeason(_ seasons: [NHLSeasonTotal]?, gameTypeId: Int) -> NHLSeasonTotal? {
        return seasons?
            .filter { $0.gameTypeId == gameTypeId && ($0.leagueAbbrev == "NHL" || $0.leagueAbbrev == "AHL") }
            .sorted(by: { ($0.season ?? 0) > ($1.season ?? 0) })
            .first
    }

    private func calculateRating(for season: NHLSeasonTotal?) -> Int? {
        guard let season = season else { return nil }
        let raw = PlayerRatingEngine.calculateRawSkaterScore(for: season)
        return PlayerRatingEngine.scaleToRating(rawScore: raw, mean: 60, stdDev: 10)
    }

    private func getHeight(from inches: Int) -> String {
        "\(inches / 12)′ \(inches % 12)″"
    }

    private func daySuffix(num: Int) -> String {
        switch num % 10 {
        case 1 where num % 100 != 11: return "st"
        case 2 where num % 100 != 12: return "nd"
        case 3 where num % 100 != 13: return "rd"
        default: return "th"
        }
    }
    
    func removeCommas(from numberString: String) -> String {
        return numberString.replacingOccurrences(of: ",", with: "")
    }
}

// Enhanced rating circle view
struct EnhancedRatingCircleView: View {
    let rating: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: CGFloat(rating) / 100.0)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: rating)
            
            VStack(spacing: 2) {
                Text("\(rating)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("RATING")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var gradientColors: [Color] {
        if rating >= 90 {
            return [.green, .mint]
        } else if rating >= 80 {
            return [.blue, .cyan]
        } else if rating >= 70 {
            return [.orange, .yellow]
        } else {
            return [.red, .pink]
        }
    }
}
