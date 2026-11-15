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
}
