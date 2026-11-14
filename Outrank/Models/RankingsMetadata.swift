//
//  RankingsMetadata.swift
//  Outrank
//

import Foundation

/// What the backend holds, independent of any team or stat.
nonisolated struct RankingsMetadata: Decodable, Equatable, Sendable {
    /// Every season with rankings, oldest first.
    let seasons: [String]

    /// When the backend last scraped the rankings. Optional, so a backend that has none
    /// to report can still list its seasons.
    let scrapedAt: Date?
}
