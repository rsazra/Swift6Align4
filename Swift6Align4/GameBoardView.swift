//
//  ContentView.swift
//  Swift6Align4
//
//  Created by Rajbir Singh Azra on 2025-01-27.
//

import SwiftUI

struct GameBoardView: View {
    @Binding var board: [[Player]]

    var body: some View {
        RoundedRectangle(cornerRadius: 14)
            .frame(width: 360, height: 390)
            .foregroundColor(.blue)
            .mask(boardOutlineView)
    }

    private var boardOutlineView: some View {
        RoundedRectangle(cornerRadius: 14)
            .frame(width: 360, height: 390)
            .foregroundColor(.white)
            .overlay(circlesView)
            .compositingGroup()
            .luminanceToAlpha()
    }

    private var circlesView: some View {
        VStack {
            ForEach(1...rows, id: \.self) { row in
                HStack {
                    ForEach(1...columns, id: \.self) { column in
                        Circle()
                            .frame(width: 40, height: 50)
                            .overlay(
                                Circle().stroke(
                                    Color.black, lineWidth: 2))
                    }
                }
            }
        }
    }
}
