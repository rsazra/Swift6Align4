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

struct AppView: View {

    @State private var board: [[Player]] = Array(
        repeating: Array(
            repeating: .none, count: columns), count: rows)
    @State private var player: Player = .red
    @State private var wins: [Player: Int] = [.red: 0, .yellow: 0, .none: 0]
    @State private var winner: Player? = nil

    var body: some View {
        VStack {
            GameBoardView(board: $board, player: $player)
            ScoreCardView(wins: $wins)
        }
    }
}

struct GameBoardView: View {
    @Binding var board: [[Player]]
    @Binding var player: Player
    let startingChipOffset: CGSize = CGSize(width: 0, height: -145)
    @State var currentChipOffset: CGSize = CGSize(width: 0, height: -145)
    //    @State var currentChipPosition: CGPoint = CGPoint(x: 0, y: 0)

    /*
     Chip y positions:
     start: -235 or -261 to keep pattern going
     level 6: -145
     level 5: -87
     level 4: -29
     level 3: 29
     level 2: 87
     level 1: 145
     so 29 is the magic number. these are all multiples of it.
     6: -5
     5: -3
     4: -1
     3: 1
     2: 3
     1: 5
     */

    /*
     Chip x positions:

     column 1: -144
     column 2: -96
     column 3: -48
     column 4: 0
     column 5: 48
     column 6: 96
     column 7: 144
     */

    func dropChip(column: Int, row: Int) {
        board[1][1] = .yellow
        board[4][4] = .red
        withAnimation(.spring()) {
            currentChipOffset.height = 145
        }
    }

    var body: some View {
        Button("test") {
            dropChip(column: 4, row: 1)
        }
        //        Spacer()
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
                    var newChipOffset = value.location.x - 180
                    if newChipOffset < -144 {
                        newChipOffset = -144
                    } else if newChipOffset > 144 {
                        newChipOffset = 144
                    }
                    currentChipOffset.width = newChipOffset
                })
                .onEnded({
                    value in
                    var endLocation = value.location.x
                    if endLocation > 0 && endLocation < 360 {
                        dropChip(column: 3, row: 4)
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
        HStack {
            ForEach(0..<columns, id: \.self) { column in
                VStack {
                    ForEach(0..<rows, id: \.self) { row in
                        let chip = board[row][column]
                        let color =
                            chip == .none
                            ? Color.clear
                            : chip == .red ? Color.red : Color.yellow
                        Circle()
                            .frame(width: 40, height: 50)
                            .foregroundColor(color)
                    }
                }
                //                .contentShape(Rectangle())
                //                .gesture(
                //                    DragGesture(minimumDistance: 0)
                //                        .onChanged { _ in currentChipOffset.width += 1 })
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
}

struct ScoreCardView: View {
    @Binding var wins: [Player: Int]
    var body: some View {
        Text("scoreCardText")
            .frame(alignment: .topLeading)
    }
}

#Preview { AppView() }
