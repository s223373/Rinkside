//
//  ContentView.swift
//  Rinkside
//
//  Created by Nik Bar on 11/24/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
                    VStack(spacing: 30) {
                        Text("Welcome to Rinkside")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 50)
                        
                        Image("rinkside_logo") // Assuming you have a logo in assets
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                        
                        NavigationLink(destination: NHLTeamsView()) {
                            HStack {
                                Image(systemName: "list.bullet.rectangle.portrait")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                Text("Explore NHL Teams")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        
                        NavigationLink(destination: NHLStandingsView()) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                Text("View Standings")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        
                        Spacer()
                    }
                    .navigationTitle("Rinkside")
                    .padding()
                }
        
    }
}

#Preview {
    ContentView()
}
