//
//  HistoryMarks.swift
//  Outrank
//

import Charts
import SwiftUI

/// What the History chart draws for one stat's season: a line through the ranked days, a
/// dot for each ranked day the line can't reach, and a larger dot where the line ends.
///
/// VoiceOver and Audio Graphs read the line, which describes every day of the season. The
/// dots mark days the line has already described, so they are hidden from both.
struct HistoryMarks: ChartContent {
    let series: HistorySeries

    private static let lineStyle = StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)

    /// Symbol areas, in points squared: a dot barely wider than the line for a lone ranked
    /// day, and a larger one that marks where the line ends.
    private static let isolatedPointArea: CGFloat = 20
    private static let latestPointArea: CGFloat = 60

    var body: some ChartContent {
        LinePlot(
            series.points,
            x: .value("Date", \.date),
            y: .value("Ranking", \.plottedRanking),
            series: .value("Stat", series.title)
        )
        .accessibilityLabel(\.accessibilityLabel)
        .accessibilityValue(\.accessibilityValue)
        .lineStyle(Self.lineStyle)

        // A ranked day with unranked days on both sides has no line to be part of.
        PointPlot(
            series.isolatedPoints,
            x: .value("Date", \.date),
            y: .value("Ranking", \.plottedRanking)
        )
        .symbolSize(Self.isolatedPointArea)
        .accessibilityHidden(true)

        if let latest = series.latest {
            PointMark(
                x: .value("Date", latest.date),
                y: .value("Ranking", latest.plottedRanking)
            )
            .symbolSize(Self.latestPointArea)
            // Its ranking's own color, not the chart-wide fill: a dot sitting on the line
            // between the two halves of the field would otherwise be drawn in both colors.
            .foregroundStyle(RankingStyle.color(for: latest.ranking))
            .accessibilityHidden(true)
        }
    }
}
