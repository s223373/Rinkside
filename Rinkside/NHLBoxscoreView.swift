//
//  NHLBoxscoreView.swift
//  Rinkside
//
//  Created by Nik Bar on 1/6/25.
//
import SwiftUI

struct NHLBoxscoreView: View {
    @State private var boxscore: NHLBoxscore?
    private let gameId: Int
    
    init(gameId: Int) {
        self.gameId = gameId
    }
    
    var body: some View {
        HStack(spacing: 20) {
            VStack {
                teamLogo(for: boxscore?.awayTeam.abbrev ?? "NHL")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text(boxscore?.awayTeam.commonName.def ?? "")
                    .font(.caption)
                    .foregroundColor(.black)
            }
            VStack {
                Text("\(boxscore?.homeTeam.score ?? 0) - \(boxscore?.awayTeam.score ?? 0)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Text(formattedDate(from: boxscore?.gameDate ?? "2025-01-01"))
                    .font(.caption)
                    .foregroundColor(.black)
            }
            VStack {
                teamLogo(for: boxscore?.awayTeam.abbrev ?? "NHL")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Text(boxscore?.awayTeam.commonName.def ?? "")
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
        .padding()
        .cornerRadius(10)
            .onAppear {
                decodeBoxscore(gameId: gameId)
            }
    }
    
    
    func decodeBoxscore(gameId: Int) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let url = NHLResource.gamecenterURL(for: gameId) else {
            print("Cannot create player URL for \(gameId)")
            return
        }
        print("Loading boxscore for \(gameId) with URL \(url.absoluteString)")
        
        let dataTask = URLSession.shared.dataTask(with: NHLResource.gamecenterURL(for: gameId)!) { dataW, response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let dataL = dataW else {
                print(error)
                return
            }
            
            do {
                let result = try decoder.decode(NHLBoxscore.self, from: dataL)
                boxscore = result
            } catch {
                print(error)
            }
        }
        dataTask.resume()
    }
    
    private func teamLogo(for teamId: String) -> Image {
            if let uiImage = UIImage(named: teamId) {
                return Image(uiImage: uiImage)
            } else {
                return Image(systemName: "photo")
            }
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
}
