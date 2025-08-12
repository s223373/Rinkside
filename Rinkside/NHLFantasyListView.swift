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
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section with create button
                        headerSection
                        
                        // Teams list or empty state
                        contentSection
                        
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
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            titleAndDeleteButton
            createTeamButton
        }
    }
    
    private var titleAndDeleteButton: some View {
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
    }
    
    private var createTeamButton: some View {
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
            .background(createButtonGradient)
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(showingCreateTeamSheet ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: showingCreateTeamSheet)
        .padding(.horizontal)
    }
    
    private var createButtonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            if fantasyTeams.isEmpty {
                EmptyStateFantasyView()
                    .padding(.top, 40)
            } else {
                teamsList
            }
        }
    }
    
    private var teamsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(fantasyTeams) { team in
                FantasyTeamCard(
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
}
