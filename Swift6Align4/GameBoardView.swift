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

let columns = 7
let rows = 6

struct GameView: View {
    @State private var board: [[Player]] = Array(
        repeating: Array(
            repeating: .none, count: rows), count: columns)
    @State private var player: Player = .red
    @State private var starter: Player = .red
    @State private var wins: [Player: Int] = [.red: 0, .yellow: 0, .none: 0]
    @State private var winner: Player? = nil
    @State private var winningChips: [(Int, Int)] = []
    @State private var playCount: Int = 0

    let startingChipOffset: CGSize = CGSize(width: 0, height: -235)
    @State var currentChipOffset: CGSize = CGSize(width: 0, height: -235)
    @State var isAnimating: Bool = false

    @State var currentColumn: Int = -1

    var body: some View {
        VStack {
            GameBoardView
            ControlsView
        }
    }

    func snapChipToGrid(currentOffset: CGFloat) -> CGFloat {
        if currentOffset > 120 { return 144 }
        if currentOffset > 72 { return 96 }
        if currentOffset > 24 { return 48 }
        if currentOffset > -24 { return 0 }
        if currentOffset > -72 { return -48 }
        if currentOffset > -120 { return -96 }
        return -144
    }

    func dropChip() {
        if isAnimating || currentColumn == -1 { return }

        let column = currentColumn
        let columnChips = board[column]
        let last = columnChips.lastIndex(of: .none)

        if last == nil {
            dropFailed()
            return
        }

        isAnimating = true
        withAnimation(.easeInOut(duration: 0.3)) {
            currentChipOffset.height = CGFloat(145 - (58 * (5 - last!)))
        } completion: {
            board[column][last!] = player
            playCount += 1
            checkEnd(column: column, row: last!)
            isAnimating = false
            if winner == nil {
                resetChip() // should be conditional on if game is over
            }
        }
    }

    func resetChip() {
        currentChipOffset.height = -235
        currentChipOffset.width = 0
        player = player == .red ? .yellow : .red
    }

    func dropFailed() {
        let endOffset = currentChipOffset.width
        withAnimation(
            .easeInOut(duration: 0.1).repeatCount(5, autoreverses: true)
        ) {
            currentChipOffset.width += 20
        }
        withAnimation(.easeInOut(duration: 0.1)) {
            currentChipOffset.width = endOffset
        }
    }

    func checkEnd(column: Int, row: Int) {
        if playCount == 42 { winner = Player.none }
        // only check around where the latest piece was dropped
        // verticals
        for i in 0..<4 {
            if (row + i - 3) >= 0, (row + i) < 6 {
                if board[column][row + i] == player,
                    board[column][row + i - 1] == player,
                    board[column][row + i - 2] == player,
                    board[column][row + i - 3] == player
                {
                    for j in 0..<4 {
                        winningChips.append((column, row + i - j))
                    }
                    winner = player
                }
            }
        }

        // horizontals
        for i in 0..<4 {
            if (column + i - 3) >= 0, (column + i) < 7 {
                if board[column + i][row] == player,
                    board[column + i - 1][row] == player,
                    board[column + i - 2][row] == player,
                    board[column + i - 3][row] == player
                {
                    for j in 0..<4 {
                        winningChips.append((column + i - j, row))
                    }
                    winner = player
                }
            }
        }

        // descending diagonals
        for i in 0..<4 {
            if (column + i - 3) >= 0, (column + i) < 7, (row + i - 3) >= 0,
                (row + i) < 6
            {
                if board[column + i][row + i] == player,
                    board[column + i - 1][row + i - 1] == player,
                    board[column + i - 2][row + i - 2] == player,
                    board[column + i - 3][row + i - 3] == player
                {
                    for j in 0..<4 {
                        winningChips.append((column + i - j, row + i - j))
                    }
                    winner = player
                }
            }
        }

        // ascending diagonals
        for i in 0..<4 {
            if (column - i) >= 0, (column - i + 3) < 7, (row + i - 3) >= 0,
                (row + i) < 6
            {
                if board[column - i][row + i] == player,
                    board[column - i + 1][row + i - 1] == player,
                    board[column - i + 2][row + i - 2] == player,
                    board[column - i + 3][row + i - 3] == player
                {
                    for j in 0..<4 {
                        winningChips.append((column - i + j, row + i - j))
                    }
                    winner = player
                }
            }
        }
    }

    private var GameBoardView: some View {
        ZStack {
            currentChip
                .offset(currentChipOffset)
            RoundedRectangle(cornerRadius: 14)
                .frame(width: 360, height: 380)
                .foregroundColor(.indigo) // indigo or blue?
                .overlay(circlesView(addStroke: true))
                .mask(boardOutlineView)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.black, lineWidth: 2))
                .dim(winner != nil)
            playedChips
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged({ value in
                    if isAnimating { return }
                    let newChipOffset: CGFloat = value.location.x - 180

                    currentChipOffset.width = snapChipToGrid(
                        currentOffset: newChipOffset)
                    currentColumn = Int(currentChipOffset.width / 48 + 3)
                })
                .onEnded({
                    value in
                    if value.location.x > 0 && value.location.x < 360 {
                        dropChip()
                    }
                    currentColumn = -1
                }))
    }

    private var currentChip: some View {
        Circle()
            .frame(width: 44, height: 50)
            .foregroundColor(player == .red ? .red : .yellow)
            .overlay(Circle().stroke(Color.black, lineWidth: 2))
    }

    private var playedChips: some View {
        VStack {
            ForEach(0..<rows, id: \.self) { row in
                HStack {
                    ForEach(0..<columns, id: \.self) { column in
                        let highlightColor = column == currentColumn ? Color.green.opacity(0.3) : Color.clear
                        let chip = board[column][row]
                        let winningChip = winner != nil ? winningChips.contains {$0 == (column, row)} : false
                        let color =
                            chip == .none
                            ? winner == nil ? highlightColor : Color.white
                            : chip == .red ? Color.red : Color.yellow
                        Circle()
                            .frame(width: 40, height: 50)
                            .foregroundColor(color)
                            .glow(color == highlightColor || winningChip)
                            .dim(!winningChip && winner != nil)
                    }
                }
            }
        }
    }

    private var boardOutlineView: some View {
        RoundedRectangle(cornerRadius: 14)
            .foregroundColor(.white)
            .overlay(circlesView())
            .compositingGroup()
            .luminanceToAlpha()
    }

    private func circlesView(addStroke: Bool = false) -> some View {
        HStack {
            ForEach(1...columns, id: \.self) { column in
                VStack {
                    ForEach(1...rows, id: \.self) { row in
                        Circle()
                            .frame(width: 40, height: 50)
                            .overlay(
                                addStroke
                                    ? Circle().stroke(Color.black, lineWidth: 4)
                                    : nil)
                    }
                }
            }
        }
    }
    
    private func resetGame() {
        player = starter == .red ? .red : .yellow
        starter = starter == .red ? .yellow : .red
        resetChip()
        board = Array(
            repeating: Array(
                repeating: .none, count: rows), count: columns)
        winner = nil
        winningChips = []
        playCount = 0
    }

    private var ControlsView: some View {
        VStack {
            Text("scoreCardText")
            Button("New Game") {
                resetGame()
            }
        }
    }
}

struct Glow: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            content.blur(radius: 10)
            content
        }
    }
}

struct Dim: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .foregroundColor(.black)
                    .opacity(0.5)
                    .mask(content)
            )
    }
}

extension View {
    @ViewBuilder
    func glow(_ glowing: Bool) -> some View {
        if glowing {
            self.modifier(Glow())
        }
        else {
            self
        }
    }
    @ViewBuilder
    func dim(_ dim: Bool) -> some View {
        if dim {
            self.modifier(Dim())
        }
        else {
            self
        }
    }
}

#Preview { GameView() }
