//
//  RankingsMetadata.swift
//  Outrank
//

import Foundation

/// What the backend holds, independent of any team or stat.
nonisolated struct RankingsMetadata: Decodable, Equatable, Sendable {
    /// Every season with rankings, oldest first.
    let seasons: [String]
}
