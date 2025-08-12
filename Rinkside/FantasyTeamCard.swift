//
//  FantasyTeamCard.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//
import SwiftUI

struct FantasyTeamCard: View {
    let team: NHLFantasyTeamLeague
    let isDeleteMode: Bool
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destinationView) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) {
            isPressed = true
        } onPressingChanged: { pressing in
            isPressed = pressing
        }
    }
    
    private var destinationView: some View {
        NHLFantasyTeamHubView(
            fantasyTeam: team.firstTeam ?? NHLFantasyTeam(name: "N/A"),
            fantasyLeague: team
        )
    }
    
    private var cardContent: some View {
        HStack {
            teamInfo
            
            if isDeleteMode {
                deleteButton
            }
        }
        .padding()
        .background(cardBackground)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private var teamInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            teamHeader
            teamStats
        }
    }
    
    private var teamHeader: some View {
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
    }
    
    private var teamStats: some View {
        HStack {
            Label("\(team.leagueSize) Teams", systemImage: "person.3.fill")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            activeStatusBadge
        }
    }
    
    private var activeStatusBadge: some View {
        Text("Active")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.green)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.green.opacity(0.1))
            .cornerRadius(4)
    }
    
    private var deleteButton: some View {
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
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
}
