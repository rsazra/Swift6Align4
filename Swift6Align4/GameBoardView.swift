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
    @State var board: [[Player]] = Array(
        repeating: Array(
            repeating: .none, count: rows), count: columns)
    @State var player: Player = .red
    @State private var wins: [Player: Int] = [.red: 0, .yellow: 0, .none: 0]
    @State private var winner: Player? = nil

    let startingChipOffset: CGSize = CGSize(width: 0, height: -235)
    @State var currentChipOffset: CGSize = CGSize(width: 0, height: -235)
    @State var isAnimating: Bool = false

    var body: some View {
        VStack {
            GameBoardView
            ScoreCardView
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
        if isAnimating { return }

        let column = Int(currentChipOffset.width / 48 + 3)
        let columnChips = board[column]
        let last = columnChips.lastIndex(of: .none)

        if last == nil {
            dropFailed()
            return
        }

        isAnimating = true
        withAnimation(.easeInOut(duration: 0.3)) {
            currentChipOffset.height = CGFloat(145 - (58 * (5 - last!)))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            board[column][last!] = player
            isAnimating = false
            resetChip()
        }

    }

    func resetChip() {
        currentChipOffset.height = -235
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

    private var GameBoardView: some View {
        ZStack {
            currentChip
                .offset(currentChipOffset)
            RoundedRectangle(cornerRadius: 14)
                .frame(width: 360, height: 380)
                .foregroundColor(.blue)
                .overlay(circlesView(addStroke: true))
                .mask(boardOutlineView)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.black, lineWidth: 2))
            playedChips
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged({ value in
                    let newChipOffset: CGFloat = value.location.x - 180

                    currentChipOffset.width = snapChipToGrid(
                        currentOffset: newChipOffset)
                })
                .onEnded({
                    value in
                    if value.location.x > 0 && value.location.x < 360 {
                        dropChip()
                    }
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
                        let chip = board[column][row]
                        let color =
                            chip == .none
                            ? Color.clear
                            : chip == .red ? Color.red : Color.yellow
                        Circle()
                            .frame(width: 40, height: 50)
                            .foregroundColor(color)
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

    private var ScoreCardView: some View {
        Text("scoreCardText")
            .frame(alignment: .topLeading)
    }
}

#Preview { GameView() }
