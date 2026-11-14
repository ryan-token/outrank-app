//
//  HistoryPoint.swift
//  Outrank
//

import SwiftUI

/// One day of a team's history in one stat, ready to plot.
nonisolated struct HistoryPoint: Equatable, Sendable {
    /// The start of the day the ranking was recorded on.
    let date: Date

    /// `nil` when the team had no ranking in the stat that day.
    let ranking: Int?

    /// Where the day sits on the ranking scale. A day with no ranking is not a number,
    /// which breaks the line there instead of drawing it through a ranking the team
    /// never had.
    var plottedRanking: Double {
        ranking.map(Double.init) ?? .nan
    }

    /// The ranking as text, such as "34th", or "Not ranked" for a day without one.
    var rankingDescription: String {
        ranking.map { Conversions.humanReadableRanking(for: $0) } ?? "Not ranked"
    }

    // The chart reads these for each point by key path, so VoiceOver and Audio Graphs can
    // describe every day on the line.
    var accessibilityLabel: Text {
        Text(date, format: .dateTime.month(.wide).day().year())
    }

    var accessibilityValue: Text {
        Text(rankingDescription)
    }
}
