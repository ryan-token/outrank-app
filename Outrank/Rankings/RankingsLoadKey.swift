//
//  RankingsLoadKey.swift
//  Outrank
//

import Foundation

/// What the Rankings screen checks for stale rankings on: the team changing, or the app
/// returning to the foreground after possibly sitting in the background for days.
struct RankingsLoadKey: Hashable {
    let team: String
    let isActive: Bool
}
