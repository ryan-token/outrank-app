//
//  HistoryPhase.swift
//  Outrank
//

import Foundation

/// Where the History screen is in getting a team's season.
nonisolated enum HistoryPhase: Equatable, Sendable {
    case loading
    case loaded

    /// The season couldn't be fetched and there is none to show in its place.
    case failed
}
