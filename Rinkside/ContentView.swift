//
//  ContentView.swift
//  Rinkside
//
//  Created by Nik Bar on 11/24/24.
//

import SwiftUI

struct ContentView: View {
    @State private var fantasyteamList: [NHLFantasyTeamLeague] = []
    @State private var animateButtons = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white, Color.blue.opacity(0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 35) {
                        // Header section
                        VStack(spacing: 20) {
                            Text("Welcome to")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text("Rinkside")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .indigo],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 2)
                        }
                        .padding(.top, 20)
                        
                        // Logo with enhanced styling
                        Group {
                            if let _ = UIImage(named: "rinkside_logo") {
                                Image("rinkside_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 140, height: 140)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                                    )
                                    .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.blue.opacity(0.8), .indigo.opacity(0.9)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 140, height: 140)
                                    
                                    Image(systemName: "hockey.puck.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                }
                                .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                            }
                        }
                        .scaleEffect(animateButtons ? 1.0 : 0.9)
                        .animation(.easeInOut(duration: 0.8), value: animateButtons)
                        
                        // Navigation buttons
                        VStack(spacing: 20) {
                            NavigationMenuButton(
                                destination: NHLTeamsView(),
                                icon: "list.bullet.rectangle.portrait",
                                title: "Explore NHL Teams",
                                subtitle: "Browse all 32 teams",
                                gradientColors: [.blue, .cyan],
                                delay: 0.1
                            )
                            
                            NavigationMenuButton(
                                destination: NHLStandingsView(),
                                icon: "trophy.fill",
                                title: "View Standings",
                                subtitle: "Current season rankings",
                                gradientColors: [.orange, .red],
                                delay: 0.2
                            )
                            
                            NavigationMenuButton(
                                destination: NHLFantasyListView(fantasyTeams: $fantasyteamList),
                                icon: "target",
                                title: "Fantasy Team",
                                subtitle: "Manage your roster",
                                gradientColors: [.green, .mint],
                                delay: 0.3
                            )
                            
                            NavigationMenuButton(
                                destination: TopPlayersView(),
                                icon: "star.fill",
                                title: "Top Scorers",
                                subtitle: "League's best players",
                                gradientColors: [.purple, .pink],
                                delay: 0.4
                            )
                        }
                        .opacity(animateButtons ? 1.0 : 0.0)
                        .offset(y: animateButtons ? 0 : 20)
                        .animation(.easeInOut(duration: 0.8).delay(0.3), value: animateButtons)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 25)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            fantasyteamList = FantasyTeamStorage.load()
            withAnimation {
                animateButtons = true
            }
        }
        .onChange(of: fantasyteamList) { _, newValue in
            FantasyTeamStorage.save(newValue)
        }
    }
}

// Custom navigation button component
struct NavigationMenuButton<Destination: View>: View {
    let destination: Destination
    let icon: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    let delay: Double
    
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 15) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    ContentView()
}
