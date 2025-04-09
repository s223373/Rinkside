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
    
    @State private var showingDateAlert = false
    @State private var dateInput = ""
    @State private var showingDatePickerSheet = false
    @State private var selectedDate = Date()
    @State private var selectedDateString = ""

        
    private let categories = ["League", "Conference", "Division"]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Category", selection: $selectedCategory) {
                                    ForEach(categories, id: \.self) { category in
                                        Text(category).tag(category)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding()
                if selectedCategory == "Conference" {
                                    List {
                                        Section(header: Text("Eastern Conference")) {
                                            ForEach(standingsTeamStats.filter { $0.conferenceName == "Eastern" }, id: \ .teamName!.def) { teamStats in
                                                teamRow(for: teamStats)
                                            }
                                        }
                                        
                                        Section(header: Text("Western Conference")) {
                                            ForEach(standingsTeamStats.filter { $0.conferenceName == "Western" }, id: \ .teamName!.def) { teamStats in
                                                teamRow(for: teamStats)
                                            }
                                        }
                                    }
                                } else if selectedCategory == "Division" {
                                    List {
                                        Section(header: Text("Atlantic Division")) {
                                            ForEach(standingsTeamStats.filter { $0.divisionName == "Atlantic" }, id: \ .teamName!.def) { teamStats in
                                                teamRow(for: teamStats)
                                            }
                                        }
                                        
                                        Section(header: Text("Metropolitan Division")) {
                                            ForEach(standingsTeamStats.filter { $0.divisionName == "Metropolitan" }, id: \ .teamName!.def) { teamStats in
                                                teamRow(for: teamStats)
                                            }
                                        }
                                        
                                        Section(header: Text("Central Division")) {
                                            ForEach(standingsTeamStats.filter { $0.divisionName == "Central" }, id: \ .teamName!.def) { teamStats in
                                                teamRow(for: teamStats)
                                            }
                                        }
                                        
                                        Section(header: Text("Pacific Division")) {
                                            ForEach(standingsTeamStats.filter { $0.divisionName == "Pacific" }, id: \ .teamName!.def) { teamStats in
                                                teamRow(for: teamStats)
                                            }
                                        }
                                    }
                                } else {
                                    List {
                                        ForEach(standingsTeamStats, id: \ .teamName!.def) { teamStats in
                                            teamRow(for: teamStats)
                                        }
                                    }
                                }
            }
            .navigationBarItems(trailing:
                HStack(spacing: 16) {
                    Button(action: {
                        decodeStandings()
                        selectedDateString = ""
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Refresh Standings")
                    
                    Button("Select Date") {
                        showingDatePickerSheet = true
                    }
                }
            )
            
            .onAppear {
                decodeStandings()
            }
            .sheet(isPresented: $showingDatePickerSheet) {
                VStack(spacing: 20) {
                    Text("Select a Date")
                        .font(.headline)
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .labelsHidden()
                    
                    Button("Load Standings") {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        selectedDateString = formatter.string(from: selectedDate)
                        decodeStandings(for: selectedDateString)
                        showingDatePickerSheet = false
                    }
                    
                    Button("Cancel", role: .cancel) {
                        showingDatePickerSheet = false
                    }
                }
                .padding()
            }
            .alert("Enter Date (YYYY-MM-DD)", isPresented: $showingDateAlert, actions: {
                TextField("2024-04-08", text: $dateInput)
                Button("OK") {
                    if isValidDate(dateInput) {
                        selectedDateString = dateInput
                        // TODO: Pass selectedDateString into your API call if needed
                        print("Selected date: \(selectedDateString)")
                        decodeStandings(for: selectedDateString)
                        
                    } else {
                        print("Invalid date format.")
                    }
                }
                Button("Cancel", role: .cancel) { }
            })
        }
    }
    
    func teamRow(for teamStats: NHLStandingsTeamStats) -> some View {
            NavigationLink(destination: NHLRosterView(teamIdentifier: teamStats.teamAbbrev?.def ?? "")) {
                HStack(spacing: 15) {
                    teamLogo(for: teamStats.teamAbbrev?.def ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(teamStats.teamName?.def ?? "Unknown")
                            .font(.headline)
                        Text(teamStatsShortDescription(from: teamStats))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack {
                    Text("\(teamStats.points ?? 0) pts")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("\(teamStats.gamesPlayed) GP")
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
            }
        }
    
    
    func decodeStandings() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let dataTask = URLSession.shared.dataTask(with: NHLResource.baseStandingsURL()!) { dataW, response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let dataL = dataW else {
                print(error)
                return
            }
            
            do {
                let result = try decoder.decode(NHLStandings.self, from: dataL)
                standingsTeamStats = result.standings
            } catch {
                print(error)
                standingsTeamStats = []
            }
        }
        dataTask.resume()
    }
    
    func decodeStandings(for date: String) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let dataTask = URLSession.shared.dataTask(with: NHLResource.dateStandingsURL(for: date)!) { dataW, response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let dataL = dataW else {
                print(error)
                return
            }
            
            do {
                let result = try decoder.decode(NHLStandings.self, from: dataL)
                standingsTeamStats = result.standings
            } catch {
                print(error)
                standingsTeamStats = []
            }
        }
        dataTask.resume()
    }
    
    private func teamLogo(for teamId: String) -> Image {
            if let uiImage = UIImage(named: teamId) {
                return Image(uiImage: uiImage)
            } else {
                return Image(systemName: "photo")  // Fallback placeholder
            }
        }
    
    func teamStatsShortDescription(from teamStats: NHLStandingsTeamStats) -> String {
        return "\(teamStats.regulationPlusOtWins ?? 0)-\(teamStats.losses ?? 0)-\(teamStats.otLosses ?? 0)"
        
    }
    
    func isValidDate(_ input: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: input) != nil
    }
    
}
