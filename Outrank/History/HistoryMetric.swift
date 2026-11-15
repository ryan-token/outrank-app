//
//  HistoryMetric.swift
//  Outrank
//

import Foundation

/// What the History chart plots for the chosen stat.
nonisolated enum HistoryMetric: String, CaseIterable, Identifiable, Sendable {
    /// Where the team ranked among FBS teams each day.
    case ranking

    /// The number behind the ranking each day, such as yards a game.
    case value

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .ranking: "Ranking"
        case .value: "Value"
        }
    }
}
