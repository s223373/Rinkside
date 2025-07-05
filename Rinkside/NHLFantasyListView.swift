//
//  NHLFantasyListView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//
import SwiftUI

struct NHLFantasyListView: View {
    @Binding var fantasyTeams: [NHLFantasyTeamLeague]
    
    @State private var showingCreateTeamSheet = false
    @State private var isDeleteMode = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section with create button
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Fantasy Hockey")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text("Manage your fantasy teams")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                
                                // Delete mode toggle
                                Button {
                                    withAnimation(.spring()) {
                                        isDeleteMode.toggle()
                                    }
                                } label: {
                                    Image(systemName: isDeleteMode ? "xmark.circle.fill" : "trash")
                                        .font(.title2)
                                        .foregroundColor(isDeleteMode ? .red : .gray)
                                        .scaleEffect(isDeleteMode ? 1.1 : 1.0)
                                }
                                .disabled(fantasyTeams.isEmpty)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Create team button
                            Button(action: {
                                showingCreateTeamSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                    Text("Create New Team")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .scaleEffect(showingCreateTeamSheet ? 0.95 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: showingCreateTeamSheet)
                            .padding(.horizontal)
                        }
                        
                        // Teams list or empty state
                        if fantasyTeams.isEmpty {
                            EmptyStateFantasyView()
                                .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(fantasyTeams) { team in
                                    TeamCard(
                                        team: team,
                                        isDeleteMode: isDeleteMode,
                                        onDelete: {
                                            withAnimation(.spring()) {
                                                if let index = fantasyTeams.firstIndex(where: { $0.id == team.id }) {
                                                    fantasyTeams.remove(at: index)
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateTeamSheet) {
                CreateTeamSheet(fantasyLeagues: $fantasyTeams)
            }
        }
    }
}

struct TeamCard: View {
    let team: NHLFantasyTeamLeague
    let isDeleteMode: Bool
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: NHLFantasyTeamHubView(fantasyTeam: team.firstTeam ?? NHLFantasyTeam(name: "N/A"), fantasyLeague: team)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(team.firstTeam?.getName() ?? "N/A")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("\(team.leagueSize ?? 6) Teams", systemImage: "person.3.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Active")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                if isDeleteMode {
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { 
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
}

struct EmptyStateFantasyView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hockey.puck")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Teams Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Create your first fantasy hockey team to get started!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Image(systemName: "arrow.up")
                .font(.title2)
                .foregroundColor(.blue)
                .opacity(0.7)
        }
        .padding()
    }
}

struct CreateTeamSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var fantasyLeagues: [NHLFantasyTeamLeague]

    @State private var teamName = ""
    @State private var leagueSize = 6 // default size

    let leagueSizes = Array(4...12)

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "hockey.puck")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("Create New Team")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Set up your fantasy hockey team")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 20) {
                            // Team Name Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Team Name")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                TextField("Enter your team name", text: $teamName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal, 4)
                                    .font(.body)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
                            )
                            
                            // League Size Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("League Size")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Picker("League Size", selection: $leagueSize) {
                                    ForEach(leagueSizes, id: \.self) { size in
                                        Text("\(size) Teams")
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 120)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
                            )
                        }
                        .padding(.horizontal)
                        
                        // Create Button
                        Button(action: {
                            if !teamName.trimmingCharacters(in: .whitespaces).isEmpty {
                                let newLeague = NHLFantasyTeamLeague(
                                    userTeamName: teamName,
                                    leagueSize: leagueSize)
                                fantasyLeagues.append(newLeague)
                                dismiss()
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                Text("Create Team")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Group {
                                    if teamName.trimmingCharacters(in: .whitespaces).isEmpty {
                                        Color.gray.opacity(0.6)
                                    } else {
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .cornerRadius(12)
                            .shadow(color: teamName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.clear : Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(teamName.trimmingCharacters(in: .whitespaces).isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
