//
//  NHLFantasyListView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//
import SwiftUI

struct NHLFantasyListView: View {
    @Binding var fantasyTeams: [NHLFantasyTeam]
    
    @State private var showingCreateTeamSheet = false
    @State private var isDeleteMode = false

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    showingCreateTeamSheet = true
                }) {
                    Label("Create New Team", systemImage: "plus")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showingCreateTeamSheet) {
                    CreateTeamSheet(fantasyTeams: $fantasyTeams)
                }

                if fantasyTeams.isEmpty {
                    Text("No teams created yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(fantasyTeams) { team in
                            HStack {
                                NavigationLink(destination: NHLFantasyTeamHubView(fantasyTeam: team)) {
                                    Text(team.getName())
                                }
                                Spacer()
                                if isDeleteMode {
                                    Button(role: .destructive) {
                                        if let index = fantasyTeams.firstIndex(where: { $0.id == team.id }) {
                                            fantasyTeams.remove(at: index)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                Spacer()
            }
            .navigationTitle("Fantasy Teams")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isDeleteMode.toggle()
                    } label: {
                        Image(systemName: isDeleteMode ? "xmark.circle" : "trash")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}


struct CreateTeamSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var fantasyTeams: [NHLFantasyTeam]
    @State private var teamName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Team Name")) {
                    TextField("Fantasy Team Name", text: $teamName)
                }
            }
            .navigationTitle("New Fantasy Team")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        if !teamName.trimmingCharacters(in: .whitespaces).isEmpty {
                            let newTeam = NHLFantasyTeam(name: teamName)
                            fantasyTeams.append(newTeam)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


