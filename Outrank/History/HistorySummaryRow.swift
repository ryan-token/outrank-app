//
//  HistorySummaryRow.swift
//  Outrank
//

import SwiftUI

/// One notable day of a season: what it was, when, and where the team ranked, with the
/// value that put it there when the backend recorded one.
struct HistorySummaryRow: View {
    let title: LocalizedStringResource
    let point: HistoryPoint

    var body: some View {
        LabeledContent {
            HStack {
                if let value = point.valueDescription {
                    StatValueBadge(value: value)
                }

                Text(point.rankingDescription)
                    .monospacedDigit()
                    .foregroundStyle(RankingStyle.color(for: point.ranking))
            }
        } label: {
            Text(title)
            Text(point.date, format: .dateTime.month(.abbreviated).day().year())
        }
    }
}
