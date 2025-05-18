//
//  NHLRosterView.swift
//  Rinkside
//
//  Created by Nik Bar on 11/26/24.
//
import SwiftUI

struct NHLRosterView: View {
    @State private var players: NHLRoster?
    @State private var prospects: NHLRoster?
    @State private var isPlayerActive: Bool = false
    @State private var isLoading: Bool = true
    private let teamId: String
    
    public init (teamIdentifier: String) {
        teamId = teamIdentifier
    }
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: NHLTeamScheduleView(teamIdentifier: teamId)) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title)
                        Text("View Full Schedule")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                }
                NavigationLink(destination: NHLClubStatsView(teamId: teamId)) {
                    HStack {
                        Image(systemName: "chart.bar")
                            .font(.title)
                        Text("View Team Stats")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                if isLoading {
                    ProgressView("Loading Roster...")
                        .padding()
                } else {
                    List {
                        createSection(title: "Forwards", players: players?.forwards)
                        createSection(title: "Defensemen", players: players?.defensemen)
                        createSection(title: "Goalies", players: players?.goalies)
                        
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Team Roster")
            .onAppear {
                decodeRoster(teamId: teamId)
                decodeProspects(teamId: teamId)
            }
        }
    }
    
    struct PlayerRow: View {
        let player: NHLPerson
        let description: String
        
        var body: some View {
            HStack(spacing: 15) {
                AsyncImage(url: URL(string: player.headshot)) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                }
                VStack(alignment: .leading) {
                    Text("\(player.firstName.def) \(player.lastName.def)")
                        .font(.body)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 5)
        }
    }
    
    @ViewBuilder
    func createSection(title: String, players: [NHLPerson]?) -> some View {
        if let players = players, !players.isEmpty {
            Section(header: Text(title).font(.headline)) {
                ForEach(players, id: \.id) { player in
                    NavigationLink(destination: NHLPlayerView(playerId: player.id)) {
                        PlayerRow(player: player, description: playerShortDescription(from: player))
                    }
                }
            }
        } else {
            EmptyView()
        }
    }
    
    func decodeRoster(teamId: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let url = NHLResource.currentRosterURL(for: teamId) else {
            print("Cannot create roster URL for \(teamId)")
            return
        }
        print("Loading roster for \(teamId) with URL \(url.absoluteString)")
        
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
                let result = try decoder.decode(NHLRoster.self, from: dataL)
                DispatchQueue.main.async {
                    players = result
                    isLoading = false
                }
            } catch {
                print(error)
            }
        }
        dataTask.resume()
    }
    
    func decodeProspects(teamId: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let url = NHLResource.currentProspectsURL(for: teamId) else {
            print("Cannot create prospects URL for \(teamId)")
            return
        }
        print("Loading prospects for \(teamId) with URL \(url.absoluteString)")
        
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
                let result = try decoder.decode(NHLRoster.self, from: dataL)
                DispatchQueue.main.async {
                    prospects = result
                    isLoading = false
                }
            } catch {
                print(error)
            }
        }
        dataTask.resume()
    }
    
    
    func playerShortDescription(from player: NHLPerson) -> String {
        return "#\(player.sweaterNumber ?? 0) | \(calculateAge(from: player.birthDate)!) yo | \(player.positionCode) | \(player.weightInPounds) lbs | \(getHeight(from: player.heightInInches)) in"
        
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
    
    struct NHLRosterView_Previews: PreviewProvider {
        static var previews: some View {
            NHLRosterView(teamIdentifier: "TOR")
        }
    }
}
