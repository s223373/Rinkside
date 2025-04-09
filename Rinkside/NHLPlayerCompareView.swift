//
//  NHLPlayerCompareView.swift
//  Rinkside
//
//  Created by Nik Bar on 4/6/25.
//
import SwiftUI

struct NHLPlayerCompareView: View {
    let player1Id: Int
    let player2Id: Int

    var body: some View {
        Text("Compare Player \(player1Id) vs Player \(player2Id)")
            .font(.title)
            .padding()
        // You could reuse NHLPlayerView logic to fetch both and lay them side by side
    }
}
