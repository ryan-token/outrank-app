//
//  HistoryReadout.swift
//  Outrank
//

import SwiftUI

/// Spells out one day above the History chart: the day being pointed at, or else the most
/// recent one with a ranking.
///
/// It keeps its space while there is no day to show, so the chart beneath it doesn't
/// jump when a season arrives.
struct HistoryReadout: View {
    @Environment(HistoryModel.self) private var model

    /// Stand in for a day while a season loads, so the placeholder is as large as a real one.
    private static let placeholderRanking = "100th"
    private static let placeholderDate = Date(timeIntervalSinceReferenceDate: 0)

    private static let dateFormat = Date.FormatStyle.dateTime
        .weekday(.abbreviated)
        .month(.abbreviated)
        .day()

    var body: some View {
        let point = model.focusedPoint
        let date = point?.date ?? Self.placeholderDate

        VStack(alignment: .leading) {
            Text(Conversions.humanReadableStat(for: model.stat))
                .font(.headline)

            Group {
                Text(point?.rankingDescription ?? Self.placeholderRanking)
                    .font(.largeTitle)
                    .bold()
                    .monospacedDigit()
                    .foregroundStyle(RankingStyle.color(for: point?.ranking))

                Text(
                    model.selectedPoint == nil
                        ? "As of \(date, format: Self.dateFormat)"
                        : "\(date, format: Self.dateFormat)"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .redacted(reason: point == nil ? .placeholder : [])
            // With no day and nothing on its way, the chart's place says why instead.
            .opacity(point == nil && model.phase != .loading ? 0 : 1)
            .accessibilityHidden(point == nil)
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview(traits: .modifier(HistoryPreviewData())) {
    HistoryReadout()
        .padding()
}
#endif
