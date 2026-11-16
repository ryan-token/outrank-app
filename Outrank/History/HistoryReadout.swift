//
//  HistoryReadout.swift
//  Outrank
//

import SwiftUI

/// Spells out one day above the History chart: the day being pointed at, or else the one
/// the line ends on, as its ranking with the stat value behind it beside it.
///
/// It keeps its space while there is no day to show, so the chart beneath it doesn't
/// jump when a season arrives.
struct HistoryReadout: View {
    @Environment(HistoryModel.self) private var model

    /// Stand in for a day while a season loads, so the placeholder is as large as a real one.
    private static let placeholderRanking = "100th"
    private static let placeholderValue = "100.0"
    private static let placeholderDate = Date(timeIntervalSinceReferenceDate: 0)

    private static let dateFormat = Date.FormatStyle.dateTime
        .weekday(.abbreviated)
        .month(.abbreviated)
        .day()

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The room between the ranking and the value when they are side by side.
    @ScaledMetric private var figureSpacing = 14.0

    var body: some View {
        let point = model.focusedPoint
        let date = point?.date ?? Self.placeholderDate
        let ranking = point?.rankingDescription ?? Self.placeholderRanking
        let rankingColor = RankingStyle.color(for: point?.ranking)
        let value = point?.valueDescription

        // The value is always laid out, and only shown when there is one. A day without one
        // then takes exactly the room of a day with one, so nothing moves as a selection
        // crosses from one to the other.
        let valueText = StatValueText(value: value ?? Self.placeholderValue)
            .font(.title3)
            .opacity(value == nil ? 0 : 1)
            .accessibilityHidden(value == nil)

        // Side by side on one baseline, until the text is too large for both
        // to fit.
        let figures = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: figureSpacing))

        VStack(alignment: .leading) {
            Text(Conversions.humanReadableStat(for: model.stat))
                .font(.headline)

            Group {
                figures {
                    Text(ranking)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(rankingColor)

                    valueText
                }
                .monospacedDigit()

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
