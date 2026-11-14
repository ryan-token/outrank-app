//
//  ComparisonEntry.swift
//  Outrank
//
//  Created by Ryan Token on 10/2/21.
//

import Foundation

/// One stat, with both compared teams' rankings in it.
nonisolated struct ComparisonEntry: Identifiable, Equatable, Sendable {
    /// The stat's API key.
    let id: String
    let title: String

    /// `nil` when the team has no ranking in the stat.
    let teamOneRanking: Int?
    let teamTwoRanking: Int?
}
