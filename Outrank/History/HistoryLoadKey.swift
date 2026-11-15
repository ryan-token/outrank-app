//
//  HistoryLoadKey.swift
//  Outrank
//

import Foundation

/// What makes the History screen check for a missing or stale season: the team or season
/// changing, or a retry after a failed load.
struct HistoryLoadKey: Hashable {
    let team: String
    let season: String?
    let reloadAttempt: Int
}
