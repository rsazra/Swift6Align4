//
//  ContentView.swift
//  Swift6Align4
//
//  Created by Rajbir Singh Azra on 2025-01-27.
//

import SwiftUI

struct ScoreCardView: View {
    var scoreCardText: String
    var body: some View {
            // Scores
//            Section {
                Text(scoreCardText)
                    .frame(width: nil, height: 100, alignment: .topLeading)
//            }
        }
    }
