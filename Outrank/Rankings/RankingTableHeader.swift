//
//  RankingTableHeader.swift
//  Outrank
//

import SwiftUI

/// The headings over a stat's table of rankings, which say what each row's two numbers are.
struct RankingTableHeader: View {
    /// The table's column of values, or `nil` when it has none.
    let valueColumn: RankingValueColumn?

    var body: some View {
        HStack {
            Text("Team")
                .frame(maxWidth: .infinity, alignment: .leading)

            if let valueColumn {
                RankingTableCell(heading: .value(valueColumn))
            }

            RankingTableCell(heading: .ranking)
        }
        .font(RankingTableColumn.headingFont)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    let column = RankingValueColumn(title: "Average", longestValue: "526.7")

    List {
        RankingTableHeader(valueColumn: column)
        RankingRow(title: "Oklahoma St.", value: "526.7", ranking: 1, inTableWith: column)
        RankingRow(
            title: "Tulsa",
            value: "402.1",
            ranking: 67,
            titleFont: .headline,
            rankingFont: .headline,
            inTableWith: column
        )
        RankingRow(title: "Old Dominion", value: "98.2", ranking: 138, inTableWith: column)
        RankingRow(title: "Sacramento St.", ranking: nil, inTableWith: column)
    }
}
