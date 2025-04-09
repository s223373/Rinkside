//
//  NHLTeamsView.swift
//  Rinkside
//
//  Created by Nik Bar on 11/24/24.
//
import SwiftUI

struct NHLTeamsView: View {
    
    @State private var teams: [NHLTeam] = []
    @State private var isTeamActive: Bool = false
    
    var filteredAndSortedTeams: [NHLTeam] {
            teams
                .filter { NHLResource.currentNHLTeams.contains($0.fullName) }
                .sorted(by: { $0.fullName < $1.fullName })
        }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredAndSortedTeams, id: \.id) { team in
                    NavigationLink(destination: NHLRosterView(teamIdentifier: team.rawTricode)) {
                        HStack(spacing: 15) {
                            teamLogo(for: team.rawTricode)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(team.fullName)
                                    .font(.headline)
                            }
                        }
                    }
                }
                
            }
        }
        .navigationTitle("NHL")
        .onAppear {
            decodeTeams()
        }
    }
    
    private func teamLogo(for teamId: String) -> Image {
            if let uiImage = UIImage(named: teamId) {
                return Image(uiImage: uiImage)
            } else {
                return Image(systemName: "photo")  // Fallback placeholder
            }
        }
    
    func decodeTeams() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let dataTask = URLSession.shared.dataTask(with: NHLResource.teamsURL()!) { dataW, response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let dataL = dataW else {
                print(error)
                return
            }
            
            do {
                let result = try decoder.decode(NHLTeams.self, from: dataL)
                teams = result.data
            } catch {
                print(error)
                teams = []
            }
        }
        dataTask.resume()
    }
    
    struct NHLTeamsView_Previews: PreviewProvider {
        static var previews: some View {
            NHLTeamsView()
        }
    }
}
