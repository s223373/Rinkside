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

                VStack(alignment: .leading, spacing: 24) {
                    Text("Player Comparison")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        HStack(alignment: .top, spacing: 0) {
                            comparisonColumn(for: p1, season: season1, isPlayoffs: isPlayoffs)
                            Divider().frame(width: 1).background(Color.gray.opacity(0.4))
                            comparisonColumn(for: p2, season: season2, isPlayoffs: isPlayoffs)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            } else {
                ProgressView("Loading players...")
                    .padding()
            }
        }
        .onAppear {
            decodePlayer(playerId: player1Id, p1Flag: true)
            decodePlayer(playerId: player2Id, p1Flag: false)
        }
    }

    private func comparisonColumn(for player: NHLPlayer, season: NHLSeasonTotal?, isPlayoffs: Bool) -> some View {
        let rating = calculateRating(for: season)

        return VStack(spacing: 16) {
            VStack {
                AsyncImage(url: URL(string: player.headshot)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                        .frame(width: 110, height: 110)
                }

                Text("\(player.firstName.def) \(player.lastName.def)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text(player.position)
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }

            if let rating = rating {
                RatingCircleView(rating: rating)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Birthplace: \(player.birthCity.def), \(player.birthCountry)")
                Text("Height: \(getHeight(from: player.heightInInches))")
                Text("Weight: \(player.weightInPounds) lbs")
                
                if let draft = player.draftDetails {
                    Text("Drafted: \(draft.overallPick)\(daySuffix(num: draft.overallPick)) overall by \(draft.teamAbbrev) in \(removeCommas(from: "\(draft.year)"))")
                } else {
                    Text("Undrafted").italic().foregroundColor(.gray)
                }
            }
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            if let season = season {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isPlayoffs ? "Latest Playoff Stats" : "Latest Regular Season Stats")
                        .font(.headline)

                    Text("League: \(season.leagueAbbrev ?? "N/A")")
                    Text("Team: \(season.teamName?.def ?? "N/A")")
                    Text("Games Played: \(season.gamesPlayed ?? 0)")
                    Text("Goals: \(season.goals ?? 0)")
                    Text("Assists: \(season.assists ?? 0)")
                    Text("Points: \(season.points ?? 0)")
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("No stats available")
                    .italic()
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .top)
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
