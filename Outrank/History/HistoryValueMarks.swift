//
//  HistoryValueMarks.swift
//  Outrank
//

import Charts
import SwiftUI

/// What the History chart draws for one stat's values over a season: a line through the
/// days that have one, a dot for each such day the line can't reach, and a larger dot
/// where the line ends.
///
/// The counterpart of `HistoryMarks`, which draws the same season's rankings. VoiceOver and
/// Audio Graphs read the line; the dots mark days it has already described.
struct HistoryValueMarks: ChartContent {
    let series: HistorySeries

    var body: some ChartContent {
        // Named for the stat, since that is what the number measures: "Scoring Offense",
        // not "Value".
        LinePlot(
            series.points,
            x: .value("Date", \.date),
            y: .value(series.title, \.plottedValue),
            series: .value("Stat", series.title)
        )
        .accessibilityLabel(\.accessibilityLabel)
        .accessibilityValue(\.valueAccessibilityValue)
        .lineStyle(HistoryMarks.lineStyle)

        // The first day the backend recorded values has no line to be part of yet, and
        // neither does a day with gaps on both sides.
        PointPlot(
            series.isolatedValuePoints,
            x: .value("Date", \.date),
            y: .value(series.title, \.plottedValue)
        )
        .symbolSize(HistoryMarks.isolatedPointArea)
        .accessibilityHidden(true)

        if let latest = series.latestValued {
            PointMark(
                x: .value("Date", latest.date),
                y: .value(series.title, latest.plottedValue)
            )
            .symbolSize(HistoryMarks.latestPointArea)
            .accessibilityHidden(true)
        }
    }
}
