//
//  CreateTeamSheet.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//
import SwiftUI

struct CreateTeamSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var fantasyLeagues: [NHLFantasyTeamLeague]

    @State private var teamName = ""
    @State private var leagueSize = 6 // default size

    let leagueSizes = Array(4...12)

    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        formSection
                        createButton
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
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.05)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    private var headerSection: some View {
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
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 20) {
            teamNameSection
            leagueSizeSection
        }
        .padding(.horizontal)
    }
    
    private var teamNameSection: some View {
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
        .background(sectionBackground)
    }
    
    private var leagueSizeSection: some View {
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
        .background(sectionBackground)
    }
    
    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Create Button
    private var createButton: some View {
        Button(action: createTeam) {
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
            .background(createButtonBackground)
            .cornerRadius(12)
            .shadow(
                color: isTeamNameValid ? Color.green.opacity(0.3) : Color.clear,
                radius: 8, x: 0, y: 4
            )
        }
        .disabled(!isTeamNameValid)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    private var isTeamNameValid: Bool {
        !teamName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var createButtonBackground: some View {
        Group {
            if isTeamNameValid {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                Color.gray.opacity(0.6)
            }
        }
    }
    
    // MARK: - Actions
    private func createTeam() {
        if isTeamNameValid {
            let newLeague = NHLFantasyTeamLeague(
                userTeamName: teamName,
                leagueSize: leagueSize
            )
            fantasyLeagues.append(newLeague)
            dismiss()
        }
    }
}
