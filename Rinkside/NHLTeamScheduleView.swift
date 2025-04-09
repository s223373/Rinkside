//
//  NHLTeamScheduleView.swift
//  Rinkside
//
//  Created by Nik Bar on 12/22/24.
//
import SwiftUI

struct NHLTeamScheduleView: View {
    @State private var teamSchedule: NHLTeamSchedule?
    
    private let teamId: String
    
    public init (teamIdentifier: String) {
        teamId = teamIdentifier
    }
    
    var body: some View {
        List {
            if let games: [NHLGame] = teamSchedule?.games, !games.isEmpty {
                ForEach(Array(games.enumerated()), id: \.offset) { index, game in
                    Button(action: {
                        NHLBoxscoreView(gameId: game.id)
                    }) {
                        HStack(spacing: 20) {
                            VStack {
                                teamLogo(for: game.homeTeam.abbrev)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                Text(game.homeTeam.abbrev)
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                            VStack {
                                Text("\(game.homeTeam.score ?? 0) - \(game.awayTeam.score ?? 0)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Text(formattedDate(from: game.gameDate))
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                            VStack {
                                teamLogo(for: game.awayTeam.abbrev)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                Text(game.awayTeam.abbrev)
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding()
                        .background(gameBackgroundColor(for: game))
                        .cornerRadius(10)
                    }
                }
            } else {
                Text("Loading schedule...")
                    .font(.headline)
                    .padding()
            }
        }            
        .onAppear {
            decodeTeamSchedule()
        }
    }
    
    private func teamLogo(for teamId: String) -> Image {
            if let uiImage = UIImage(named: teamId) {
                return Image(uiImage: uiImage)
            } else {
                return Image(systemName: "photo")
            }
        }
    
    private func gameBackgroundColor(for game: NHLGame) -> Color {
        if (game.awayTeam.score ?? -1 == game.homeTeam.score ?? -1) {
            return .yellow
        }
            if game.homeTeam.abbrev == teamId {
                // If the current team is the home team
                if game.homeTeam.score ?? -1 > game.awayTeam.score ?? -1 {
                    return .green  // Home team wins
                } else {
                    return .red  // Home team loses
                }
            } else if game.awayTeam.abbrev == teamId {
                // If the current team is the away team
                if game.awayTeam.score ?? -1 > game.homeTeam.score ?? -1 {
                    return .green  // Away team wins
                } else {
                    return .red  // Away team loses
                }
            }
            return .yellow  // Default background if the game doesn't involve the current team
        }
    
    private func formattedDate(from isoDate: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM d"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: isoDate) else {
            return isoDate  // Return original string if parsing fails
        }
        
        let day = Calendar.current.component(.day, from: date)
        let suffix = daySuffix(day: day)
        
        return outputFormatter.string(from: date) + suffix + ", " + outputFormatter.string(from: date)
    }

    // Helper to add 'st', 'nd', 'rd', 'th' to day
    private func daySuffix(day: Int) -> String {
        switch day {
        case 11...13:
            return "th"
        default:
            switch day % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }
    
    private func validURL(for logo: String?) -> URL? {
            guard let logo = logo, let url = URL(string: logo) else {
                return URL(string: "https://example.com/placeholder.png")  // Fallback placeholder image
            }
            return url
        }
    
    func decodeTeamSchedule() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let url = NHLResource.baseTeamScheduleURL(for: teamId) else {
            print("Invalid URL")
            return
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { dataW, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let dataL = dataW else {
                print("No data received")
                return
            }
            
            do {
                let result = try decoder.decode(NHLTeamSchedule.self, from: dataL)
                    DispatchQueue.main.async {
                        teamSchedule = result
                    }
            } catch let DecodingError.keyNotFound(key, context) {
                print("Missing key: \(key.stringValue) – \(context.debugDescription)")
            } catch let DecodingError.typeMismatch(_, context) {
                print("Type mismatch – \(context.debugDescription)")
            } catch let error {
                print("Failed to decode: \(error)")
            }
        }
        dataTask.resume()
    }
}
