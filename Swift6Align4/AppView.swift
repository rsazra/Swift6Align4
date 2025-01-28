//
//  AppView.swift
//  Swift6Align4
//
//  Created by Rajbir Singh Azra on 2025-01-27.
//

import SwiftUI

enum Player {
    case red, yellow, none
}

let columns = 7
let rows = 6

struct AppView: View {

    @State private var board: [[Player]] = Array(
        repeating: Array(
            repeating: .none, count: columns), count: rows)
    @State private var player: Player = .red
    @State private var wins: [Player: Int] = [:]
    @State private var winner: Player? = nil

    private var scoreCardText: String {
        if winner != nil {
            return "Game Over!"
        } else {
            return "test"
        }
    }

    var body: some View {
        VStack {
            // bind board to gameboard view?
            GameBoardView(board: $board)
            ScoreCardView(scoreCardText: scoreCardText)
        }
    }
}

#Preview {
    AppView()
}
