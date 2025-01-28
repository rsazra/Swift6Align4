//
//  ContentView.swift
//  Swift6Align4
//
//  Created by Rajbir Singh Azra on 2025-01-27.
//

import SwiftUI

enum Player {
    case red, yellow, none
}

struct Connect4Board: View {
    let columns = 7
    let rows = 6

    @State private var board: [[Player]] = Array(
        repeating: Array(repeating: .none, count: 7), count: 6)
    @State private var player: Player = .red
    @State private var winner: Player? = nil
    private var scoreCardText: String {
        if winner != nil {
            return "Game Over!"
        } else {
            return ""
        }
    }
    
    var body: some View {
        VStack {
            // Board
            Section {
                VStack {
                    ForEach(1...rows, id: \.self) { row in
                        HStack {
                            ForEach(1...columns, id: \.self) { column in
                                Circle()
                                    .fill(Color.white)  // Empty slot
                                    .frame(width: 40, height: 50)
                                    .overlay(
                                        Circle().stroke(
                                            Color.black, lineWidth: 2))
//                                    .padding(1)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black, lineWidth: 2)
            )
            // Scores
            Section {
                Text(scoreCardText)
                    .frame(width: nil, height: 100, alignment: .topLeading)
            }
        }
    }
}

struct Connect4Board_Previews: PreviewProvider {
    static var previews: some View {
        Connect4Board()
    }
}
