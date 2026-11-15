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

    /// The stat value behind the ranking. `nil` when the team had none that day, or the
    /// backend wasn't recording values yet.
    let value: Double?

    /// `value` as text, such as "33.6", or `nil` for a day without one.
    let valueDescription: String?

    init(date: Date, ranking: Int?, value: Double? = nil, valueDescription: String? = nil) {
        self.date = date
        self.ranking = ranking
        self.value = value
        self.valueDescription = valueDescription
    }

    /// Where the day sits on the ranking scale. A day with no ranking is not a number,
    /// which breaks the line there instead of drawing it through a ranking the team
    /// never had.
    var plottedRanking: Double {
        ranking.map(Double.init) ?? .nan
    }

    /// Where the day sits on the value scale. Not a number on a day without a value, for
    /// the same reason.
    var plottedValue: Double {
        value ?? .nan
    }

    /// The ranking as text, such as "34th", or "Unknown" for a day without one.
    var rankingDescription: String {
        Conversions.humanReadableRanking(for: ranking)
    }

    // The chart reads these for each point by key path, so VoiceOver and Audio Graphs can
    // describe every day on the line.
    var accessibilityLabel: Text {
        Text(date, format: .dateTime.month(.wide).day().year())
    }

    var accessibilityValue: Text {
        Text(rankingDescription)
    }

    var valueAccessibilityValue: Text {
        valueDescription.map { Text($0) } ?? Text("No Value")
    }
}
