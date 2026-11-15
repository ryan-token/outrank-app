//
//  TeamHistory.swift
//  Outrank
//

import Foundation

/// One team's ranking in every stat on each day of a season.
nonisolated struct TeamHistory: Decodable, Equatable, Sendable {
    /// The season the days belong to, named for the year it kicks off in.
    let season: String

    /// The days the backend has rankings for, oldest first, as `yyyy-MM-dd`.
    let dates: [String]

    /// Each stat's rankings, lined up with `dates`. A `nil` marks a day the team had no
    /// ranking in the stat.
    let ranks: [String: [Int?]]
}
