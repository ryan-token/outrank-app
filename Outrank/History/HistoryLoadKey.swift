//
//  HistoryLoadKey.swift
//  Outrank
//

import Foundation

/// What the History screen checks for a missing or stale season on: the team or season
/// changing, a retry after a failed load, or the app returning to the foreground after
/// possibly sitting in the background for days.
struct HistoryLoadKey: Hashable {
    let team: String
    let season: String?
    let reloadAttempt: Int
    let isActive: Bool
}
