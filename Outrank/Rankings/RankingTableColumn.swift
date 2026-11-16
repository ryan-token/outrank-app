//
//  RankingTableColumn.swift
//  Outrank
//

import SwiftUI

/// One of the columns that follow the team's name in a stat's table of rankings.
enum RankingTableColumn {
    /// Each team's value in the stat.
    case value(RankingValueColumn)

    case ranking

    /// What the table's headings are set in: the size of the names under them, and heavier.
    static let headingFont = Font.headline

    var title: LocalizedStringResource {
        switch self {
        case .value(let column): column.title
        case .ranking: "Ranking"
        }
    }
}
