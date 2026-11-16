//
//  RankingValueColumn.swift
//  Outrank
//

import Foundation

/// The column of values in a stat's table of rankings.
struct RankingValueColumn {
    /// What the stat's values are, such as "Average": the column's heading.
    let title: LocalizedStringResource

    /// The longest of the values as text, which every row makes room for so the values
    /// line up down the table.
    let longestValue: String
}

extension RankingValueColumn {
    /// The column for a stat's values, or `nil` when no team has one and the table has
    /// no column for them.
    init?(stat: String, longestValue: String?) {
        guard let longestValue else { return nil }
        self.init(title: AllStats.valueFormat(for: stat).columnTitle, longestValue: longestValue)
    }
}
