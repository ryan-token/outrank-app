//
//  TeamHistory.swift
//  Outrank
//

import Foundation
import OSLog

/// One team's ranking and value in every stat on each day of a season.
nonisolated struct TeamHistory: Decodable, Equatable, Sendable {
    /// The season the days belong to, named for the year it kicks off in.
    let season: String

    /// The days the backend has rankings for, oldest first, as `yyyy-MM-dd`.
    let dates: [String]

    /// Each stat's rankings, lined up with `dates`. A `nil` marks a day the team had no
    /// ranking in the stat.
    let ranks: [String: [Int?]]

    /// Each stat's values, lined up with `dates` the way `ranks` is. A `nil` marks a day
    /// without one: every day from before the backend read values, as well as the days the
    /// team had no ranking. A stat with no value all season is left out.
    let values: [String: [Double?]]

    init(season: String, dates: [String], ranks: [String: [Int?]], values: [String: [Double?]] = [:]) {
        self.season = season
        self.dates = dates
        self.ranks = ranks
        self.values = values
    }

    private static let logger = Logger(category: "TeamHistory")

    private enum CodingKeys: CodingKey {
        case season
        case dates
        case ranks
        case values
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        season = try container.decode(String.self, forKey: .season)
        dates = try container.decode([String].self, forKey: .dates)
        ranks = try container.decode([String: [Int?]].self, forKey: .ranks)
        // A backend from before values were stored sends none. Values that can't be read
        // are left out too: rankings are worth showing without them.
        do {
            values = try container.decodeIfPresent([String: [Double?]].self, forKey: .values) ?? [:]
        } catch {
            Self.logger.error("Ignoring values that could not be decoded: \(String(describing: error))")
            values = [:]
        }
    }
}
