//
//  RankingEntry.swift
//  Outrank
//

import Foundation

/// One row of rankings: a stat with the selected team's ranking in it, or a team with its
/// ranking in one stat.
///
/// Built once when rankings load or the sort order changes, so rows can display it
/// without recomputing names or lookups during view updates.
nonisolated struct RankingEntry: Identifiable, Equatable, Sendable {
    /// The API's name for the row: a stat key or a team name. Stable across reloads, so
    /// it identifies the row in lists and navigation.
    let id: String

    /// The human-readable name shown in the row.
    let title: String

    /// `nil` when the team has no ranking in the stat.
    let ranking: Int?

    /// The stat value behind the ranking, formatted for display, such as "534.7". `nil`
    /// when there is none to show, or on a screen that lists rankings alone.
    let value: String?

    init(id: String, title: String, ranking: Int?, value: String? = nil) {
        self.id = id
        self.title = title
        self.ranking = ranking
        self.value = value
    }
}
