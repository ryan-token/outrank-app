//
//  RankingsSnapshot.swift
//  Outrank
//

import Foundation

/// The rankings from one scrape of ncaa.com: either one team's ranking in every stat, or
/// every team's ranking in one stat.
nonisolated struct RankingsSnapshot: Decodable, Equatable, Sendable {
    /// How long a loaded snapshot counts as current. The backend scrapes twice a day, so
    /// an hour avoids refetching on every tab switch without letting a long-lived session
    /// fall behind an update.
    static let maxAge: TimeInterval = 60 * 60

    /// Whether rankings that arrived at `loadedAt` still count as current at `now`.
    static func isCurrent(loadedAt: Date?, now: Date) -> Bool {
        loadedAt.map { now.timeIntervalSince($0) < maxAge } ?? false
    }

    /// Rankings keyed by stat for a team, or by team name for a stat. The backend leaves
    /// out a name that has no ranking, either because the team has recorded none of the
    /// stat or because it has not played yet.
    let ranks: [String: Int]
}
