//
//  HistoryReadout.swift
//  Outrank
//

import SwiftUI

/// Spells out one day above the History chart: the day being pointed at, or else the one
/// the plotted line ends on. What the chart plots is the larger figure, with the day's
/// ranking or value beside it.
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

    var body: some View {
        let point = model.focusedPoint
        let date = point?.date ?? Self.placeholderDate
        let showsValue = model.plottedMetric == .value
        let ranking = point?.rankingDescription ?? Self.placeholderRanking
        let rankingColor = RankingStyle.color(for: point?.ranking)
        // While a season loads, the placeholder stands for whatever the chart last plotted.
        let value = point == nil ? (showsValue ? Self.placeholderValue : nil) : point?.valueDescription

        // Side by side on a shared baseline, until the text is too large for both to fit.
        let figures = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))

        VStack(alignment: .leading) {
            Text(Conversions.humanReadableStat(for: model.stat))
                .font(.headline)

            Group {
                figures {
                    // A day pointed at on the value chart can be one without a value.
                    Text(showsValue ? value ?? String(localized: "No Value") : ranking)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(showsValue ? AnyShapeStyle(.primary) : AnyShapeStyle(rankingColor))

                    if let secondary = showsValue ? ranking : value {
                        Text(secondary)
                            .font(.title3)
                            .foregroundStyle(showsValue ? AnyShapeStyle(rankingColor) : AnyShapeStyle(.secondary))
                    }
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

#Preview("Values", traits: .modifier(HistoryPreviewData(metric: .value))) {
    HistoryReadout()
        .padding()
}
#endif
