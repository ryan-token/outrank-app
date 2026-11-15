//
//  RankingsSnapshot.swift
//  Outrank
//

import Foundation

/// The rankings from one scrape of ncaa.com, with the stat values behind them: either one
/// team's in every stat, or every team's in one stat.
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

    /// The number behind each ranking, keyed the way `ranks` is: 534.7 yards a game behind
    /// 1st in Total Offense. A percentage is a fraction (0.589), and Time Of Possession is
    /// in minutes a game. A ranking can lack a value, so `AllStats.valueFormat(for:)`
    /// formats the ones there are and rows show nothing for the rest.
    let values: [String: Double]

    init(ranks: [String: Int], values: [String: Double] = [:]) {
        self.ranks = ranks
        self.values = values
    }

    private enum CodingKeys: CodingKey {
        case ranks
        case values
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ranks = try container.decode([String: Int].self, forKey: .ranks)
        // The backend leaves `values` out of rankings it scraped before it read them.
        values = try container.decodeIfPresent([String: Double].self, forKey: .values) ?? [:]
    }
}
