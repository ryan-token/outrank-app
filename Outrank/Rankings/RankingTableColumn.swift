//
//  RankingTableColumn.swift
//  Outrank
//

import SwiftUI

/// One of the columns that follow the team's name in a stat's table of rankings.
enum RankingTableColumn {
    /// Each team's value in the stat. `longest` is the longest of them as text, which every
    /// row makes room for so the values line up down the table.
    case value(longest: String)

    case ranking

    /// What the table's headings are set in: the size of the names under them, and heavier.
    static let headingFont = Font.headline

    var title: LocalizedStringResource {
        switch self {
        case .value: "Value"
        case .ranking: "Ranking"
        }
    }

    /// Values are centered under their heading; rankings keep to the trailing edge, as
    /// they do in every other list.
    var alignment: Alignment {
        switch self {
        case .value: .center
        case .ranking: .trailing
        }
    }
}
