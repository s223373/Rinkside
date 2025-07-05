//
//  NHLStandingsView.swift
//  Rinkside
//
//  Created by Nik Bar on 1/2/25.
//

import SwiftUI

struct NHLStandingsView: View {
    @State private var standingsTeamStats: [NHLStandingsTeamStats] = []
    @State private var selectedCategory: String = "League"
    @State private var isLoading: Bool = true
    @State private var selectedDate = Date()
    @State private var selectedDateString = ""
    @State private var showingDatePickerSheet = false
    
    private let categories = ["League", "Conference", "Division"]
    
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
                
                VStack(spacing: 0) {
                    // Enhanced category picker
                    VStack(spacing: 16) {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 20)
                        
                        // Date indicator
                        if !selectedDateString.isEmpty {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                Text("Standings for \(selectedDateString)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("Current") {
                                    selectedDateString = ""
                                    decodeStandings()
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.1))
                            )
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 8)
                    .background(Color(.systemBackground))
                    
                    if isLoading {
                        Spacer()
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.blue)
                            Text("Loading Standings...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        standingsContent
                    }
                }
            }
            .navigationTitle("NHL Standings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: {
                            refreshStandings()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Refresh Standings")
                        
                        Button(action: {
                            showingDatePickerSheet = true
                        }) {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Select Date")
                    }
                }
            }
            .onAppear {
                if standingsTeamStats.isEmpty {
                    decodeStandings()
                }
            }
            .sheet(isPresented: $showingDatePickerSheet) {
                DatePickerSheet(
                    selectedDate: $selectedDate,
                    selectedDateString: $selectedDateString,
                    onDateSelected: { dateString in
                        decodeStandings(for: dateString)
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private var standingsContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if selectedCategory == "Conference" {
                    conferenceStandings
                } else if selectedCategory == "Division" {
                    divisionStandings
                } else {
                    leagueStandings
                }
            }
            .padding(.top, 8)
        }
        .refreshable {
            await refreshStandingsAsync()
        }
    }
    
    @ViewBuilder
    private var conferenceStandings: some View {
        StandingsSection(
            title: "Eastern Conference",
            teams: standingsTeamStats.filter { $0.conferenceName == "Eastern" }
        )
        
        StandingsSection(
            title: "Western Conference",
            teams: standingsTeamStats.filter { $0.conferenceName == "Western" }
        )
    }
    
    @ViewBuilder
    private var divisionStandings: some View {
        StandingsSection(
            title: "Atlantic Division",
            teams: standingsTeamStats.filter { $0.divisionName == "Atlantic" }
        )
        
        StandingsSection(
            title: "Metropolitan Division",
            teams: standingsTeamStats.filter { $0.divisionName == "Metropolitan" }
        )
        
        StandingsSection(
            title: "Central Division",
            teams: standingsTeamStats.filter { $0.divisionName == "Central" }
        )
        
        StandingsSection(
            title: "Pacific Division",
            teams: standingsTeamStats.filter { $0.divisionName == "Pacific" }
        )
    }
    
    @ViewBuilder
    private var leagueStandings: some View {
        StandingsSection(
            title: "NHL Standings",
            teams: standingsTeamStats
        )
    }
    
    private func refreshStandings() {
        isLoading = true
        selectedDateString = ""
        decodeStandings()
    }
    
    private func refreshStandingsAsync() async {
        isLoading = true
        if selectedDateString.isEmpty {
            decodeStandings()
        } else {
            decodeStandings(for: selectedDateString)
        }
    }
    
    private func decodeStandings() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let dataTask = URLSession.shared.dataTask(with: NHLResource.baseStandingsURL()!) { dataW, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching standings: \(error)")
                    isLoading = false
                    return
                }
                
                guard let dataL = dataW else {
                    print("No data received")
                    isLoading = false
                    return
                }
                
                do {
                    let result = try decoder.decode(NHLStandings.self, from: dataL)
                    standingsTeamStats = result.standings
                    isLoading = false
                } catch {
                    print("Decoding error: \(error)")
                    standingsTeamStats = []
                    isLoading = false
                }
            }
        }
        dataTask.resume()
    }
    
    private func decodeStandings(for date: String) {
        isLoading = true
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let dataTask = URLSession.shared.dataTask(with: NHLResource.dateStandingsURL(for: date)!) { dataW, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching standings for date: \(error)")
                    isLoading = false
                    return
                }
                
                guard let dataL = dataW else {
                    print("No data received for date")
                    isLoading = false
                    return
                }
                
                do {
                    let result = try decoder.decode(NHLStandings.self, from: dataL)
                    standingsTeamStats = result.standings
                    isLoading = false
                } catch {
                    print("Decoding error for date: \(error)")
                    standingsTeamStats = []
                    isLoading = false
                }
            }
        }
        dataTask.resume()
    }
}

struct StandingsSection: View {
    let title: String
    let teams: [NHLStandingsTeamStats]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(teams.count) teams")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(teams.enumerated()), id: \.element.teamName?.def) { index, teamStats in
                    StandingsTeamRow(teamStats: teamStats, position: index + 1)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 24)
    }
}

struct StandingsTeamRow: View {
    let teamStats: NHLStandingsTeamStats
    let position: Int
    
    var body: some View {
        NavigationLink(destination: NHLRosterView(teamIdentifier: teamStats.teamAbbrev?.def ?? "")) {
            HStack(spacing: 16) {
                // Position indicator
                Text("\(position)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(width: 24, alignment: .center)
                
                // Team logo
                teamLogo(for: teamStats.teamAbbrev?.def ?? "")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(teamStats.teamName?.def ?? "Unknown")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(teamStatsDescription(from: teamStats))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(teamStats.points ?? 0)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("PTS")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(teamStats.gamesPlayed)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("GP")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
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
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func teamLogo(for teamId: String) -> Image {
        if let uiImage = UIImage(named: teamId) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "sportscourt.fill")
        }
    }
    
    private func teamStatsDescription(from teamStats: NHLStandingsTeamStats) -> String {
        return "\(teamStats.regulationPlusOtWins ?? 0)-\(teamStats.losses ?? 0)-\(teamStats.otLosses ?? 0)"
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var selectedDateString: String
    let onDateSelected: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    Text("Select Date")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("View standings for a specific date")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .labelsHidden()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
                
                VStack(spacing: 12) {
                    Button(action: {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let dateString = formatter.string(from: selectedDate)
                        selectedDateString = dateString
                        onDateSelected(dateString)
                        dismiss()
                    }) {
                        Text("Load Standings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                    }
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(24)
            .navigationBarHidden(true)
        }
    }
}
