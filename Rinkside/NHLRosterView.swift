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
    @State private var seasonId: String = "20242025"
    @State private var showingStats = false
    private let teamId: String
    
    public init (teamIdentifier: String) {
        teamId = teamIdentifier
    }
    
    private let availableSeasons = [
        "20242025", "20232024", "20222023", "20212022", "20202021"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section with action buttons
                    headerSection
                    
                    if isLoading {
                        loadingView
                    } else {
                        rosterContent
                    }
                }
            }
            .navigationTitle("Team Roster")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                seasonSelectionMenu
            }
            .onAppear {
                decodeRoster(teamId: teamId, seasonId: seasonId)
                decodeProspects(teamId: teamId)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Schedule button
            NavigationLink(destination: NHLTeamScheduleView(teamIdentifier: teamId)) {
                ActionButton(
                    icon: "calendar",
                    title: "View Full Schedule",
                    subtitle: "Games & Results",
                    backgroundColor: .blue,
                    foregroundColor: .white
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Stats button - Using NavigationLink with dynamic destination
            NavigationLink(
                destination: NHLClubStatsView(teamId: teamId, seasonId: seasonId),
                isActive: $showingStats
            ) {
                Button(action: {
                    showingStats = true
                }) {
                    ActionButton(
                        icon: "chart.bar.fill",
                        title: "View Team Stats",
                        subtitle: "Performance Analytics",
                        backgroundColor: .green,
                        foregroundColor: .white
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text("Loading Roster...")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Roster Content
    private var rosterContent: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Current roster sections
                createSection(title: "Forwards", players: players?.forwards, icon: "figure.hockey", color: .red)
                createSection(title: "Defensemen", players: players?.defensemen, icon: "shield.fill", color: .blue)
                createSection(title: "Goalies", players: players?.goalies, icon: "target", color: .orange)
                
                // Prospects sections (filtered to remove current roster players)
                createSection(title: "Prospect Forwards", players: filteredProspects(prospects?.forwards), icon: "star.fill", color: .purple)
                createSection(title: "Prospect Defensemen", players: filteredProspects(prospects?.defensemen), icon: "star.circle.fill", color: .indigo)
                createSection(title: "Prospect Goalies", players: filteredProspects(prospects?.goalies), icon: "star.square.fill", color: .mint)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Season Selection Menu
    private var seasonSelectionMenu: some View {
        Menu {
            ForEach(availableSeasons, id: \.self) { season in
                Button(action: {
                    seasonId = season
                    isLoading = true
                    decodeRoster(teamId: teamId, seasonId: seasonId)
                    decodeProspects(teamId: teamId)
                }) {
                    HStack {
                        Text("\(formattedSeason(season))")
                        if season == seasonId {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Image(systemName: "calendar")
                Text(formattedSeason(seasonId))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray5))
            .foregroundColor(.primary)
            .cornerRadius(20)
        }
    }
    
    // MARK: - Action Button Component
    struct ActionButton: View {
        let icon: String
        let title: String
        let subtitle: String
        let backgroundColor: Color
        let foregroundColor: Color
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .background(foregroundColor.opacity(0.2))
                    .foregroundColor(foregroundColor)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(subtitle)
                        .font(.caption)
                        .opacity(0.8)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .opacity(0.6)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(backgroundColor.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(backgroundColor.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(16)
        }
    }
    
    // MARK: - Player Row Component
    struct PlayerRow: View {
        let player: NHLPerson
        let description: String
        
        var body: some View {
            HStack(spacing: 16) {
                // Player headshot
                AsyncImage(url: URL(string: player.headshot)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                } placeholder: {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.secondary)
                        )
                }
                
                // Player info
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(player.firstName.def) \(player.lastName.def)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Jersey number
                if let jerseyNumber = player.sweaterNumber {
                    Text("#\(jerseyNumber)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color(.systemGray4).opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }
    
    // MARK: - Section Creation
    @ViewBuilder
    func createSection(title: String, players: [NHLPerson]?, icon: String, color: Color) -> some View {
        if let players = players, !players.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                // Section header
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                        .frame(width: 32, height: 32)
                        .background(color.opacity(0.1))
                        .clipShape(Circle())
                    
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(players.count) players")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 4)
                
                // Players list
                LazyVStack(spacing: 8) {
                    ForEach(players, id: \.id) { player in
                        NavigationLink(destination: NHLPlayerView(playerId: player.id)) {
                            PlayerRow(player: player, description: playerShortDescription(from: player))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
    
    // MARK: - Network Functions
    func decodeRoster(teamId: String, seasonId: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let url = NHLResource.currentRosterURL(for: teamId, with: seasonId) else {
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
    
    // MARK: - Helper Functions
    func formattedSeason(_ seasonId: String) -> String {
        let start = seasonId.prefix(4)
        let end = seasonId.suffix(4)
        return "\(start)-\(end)"
    }
    
    func filteredProspects(_ prospectPlayers: [NHLPerson]?) -> [NHLPerson]? {
        guard let prospectPlayers = prospectPlayers else { return nil }
        
        // Get all current roster player IDs
        var currentRosterPlayerIds = Set<String>()
        
        if let forwards = players?.forwards {
                    for player in forwards {
                        currentRosterPlayerIds.insert("\(player.id)")
                    }
                }
                if let defensemen = players?.defensemen {
                    for player in defensemen {
                        currentRosterPlayerIds.insert("\(player.id)")
                    }
                }
                if let goalies = players?.goalies {
                    for player in goalies {
                        currentRosterPlayerIds.insert("\(player.id)")
                    }
                }
                
        // Filter out prospects who are already in the current roster
        let filteredProspects = prospectPlayers.filter { prospect in
            !currentRosterPlayerIds.contains("\(prospect.id)")
        }
        
        return filteredProspects.isEmpty ? nil : filteredProspects
    }
    
    func playerShortDescription(from player: NHLPerson) -> String {
        let age = calculateAge(from: player.birthDate) ?? 0
        let height = getHeight(from: player.heightInInches)
        return "\(age) yo • \(player.positionCode) • \(player.weightInPounds) lbs • \(height)"
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
        return "\(heightInInches / 12)' \(heightInInches % 12)\""
    }
    
    struct NHLRosterView_Previews: PreviewProvider {
        static var previews: some View {
            NHLRosterView(teamIdentifier: "TOR")
        }
    }
}
