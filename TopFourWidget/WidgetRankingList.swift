//
//  WidgetRankingList.swift
//  TopFourWidgetExtension
//

import SwiftUI

/// The trailing side of the widget: one row per stat, spread over its height.
struct WidgetRankingList: View {
    let entries: [RankingEntry]

    var body: some View {
        if entries.isEmpty {
            Text("No rankings yet")
                .font(.subheadline)
                .opacity(0.85)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: 0) {
                ForEach(entries) { entry in
                    WidgetRankingRow(title: entry.title, ranking: entry.ranking)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.leading)
        }
    }
}
