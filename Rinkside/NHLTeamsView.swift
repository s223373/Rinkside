//
//  NHLTeamsView.swift
//  Rinkside
//
//  Created by Nik Bar on 11/24/24.
//

import SwiftUI

struct NHLTeamsView: View {
    
    @State private var teams: [NHLTeam] = []
    @State private var isLoading: Bool = true
    @State private var searchText: String = ""
    
    var filteredAndSortedTeams: [NHLTeam] {
        let filtered = teams
            .filter { NHLResource.currentNHLTeams.contains($0.fullName) }
            .sorted(by: { $0.fullName < $1.fullName })
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemBackground),
                        Color(.systemGray6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        Text("Loading NHL Teams...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredAndSortedTeams, id: \.id) { team in
                                NavigationLink(destination: NHLRosterView(teamIdentifier: team.rawTricode)) {
                                    TeamCardView(team: team)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .refreshable {
                        await refreshTeams()
                    }
                }
            }
            .navigationTitle("NHL Teams")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search teams...")
            .onAppear {
                if teams.isEmpty {
                    decodeTeams()
                }
            }
        }
    }
    
    private func refreshTeams() async {
        isLoading = true
        decodeTeams()
    }
    
    private func decodeTeams() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let dataTask = URLSession.shared.dataTask(with: NHLResource.teamsURL()!) { dataW, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching teams: \(error)")
                    isLoading = false
                    return
                }
                
                guard let dataL = dataW else {
                    print("No data received")
                    isLoading = false
                    return
                }
                
                do {
                    let result = try decoder.decode(NHLTeams.self, from: dataL)
                    teams = result.data
                    isLoading = false
                } catch {
                    print("Decoding error: \(error)")
                    teams = []
                    isLoading = false
                }
            }
        }
        dataTask.resume()
    }
}

struct TeamCardView: View {
    let team: NHLTeam
    
    var body: some View {
        HStack(spacing: 16) {
            // Team logo with enhanced styling
            teamLogo(for: team.rawTricode)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.primary.opacity(0.1), lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(team.fullName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(team.rawTricode)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.2), value: team.id)
    }
    
    private func teamLogo(for teamId: String) -> Image {
        if let uiImage = UIImage(named: teamId) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "sportscourt.fill")
        }
    }
}

struct NHLTeamsView_Previews: PreviewProvider {
    static var previews: some View {
        NHLTeamsView()
            .preferredColorScheme(.light)
        
        NHLTeamsView()
            .preferredColorScheme(.dark)
    }
}
