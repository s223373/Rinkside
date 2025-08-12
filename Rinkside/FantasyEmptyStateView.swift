//
//  EmptyStateFantasyView.swift
//  Rinkside
//
//  Created by Nik Bar on 5/18/25.
//
import SwiftUI

struct EmptyStateFantasyView: View {
    var body: some View {
        VStack(spacing: 20) {
            puckIcon
            textContent
            arrowIcon
        }
        .padding()
    }
    
    private var puckIcon: some View {
        Image(systemName: "hockey.puck")
            .font(.system(size: 60))
            .foregroundColor(.gray.opacity(0.5))
    }
    
    private var textContent: some View {
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
    }
    
    private var arrowIcon: some View {
        Image(systemName: "arrow.up")
            .font(.title2)
            .foregroundColor(.blue)
            .opacity(0.7)
    }
}

