//
//  RankingTableHeader.swift
//  Outrank
//

import SwiftUI

/// The headings over a stat's table of rankings, which say what each row's two numbers are.
struct RankingTableHeader: View {
    /// The longest value in the table, or `nil` when it has no values and so no column
    /// for them.
    let longestValue: String?

    var body: some View {
        HStack {
            Text("Team")
                .frame(maxWidth: .infinity, alignment: .leading)

            if let longestValue {
                RankingTableCell(heading: .value(longest: longestValue))
            }

            RankingTableCell(heading: .ranking)
        }
        .font(RankingTableColumn.headingFont)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    List {
        RankingTableHeader(longestValue: "526.7")
        RankingRow(title: "Oklahoma St.", value: "526.7", ranking: 1, inTableWithLongestValue: "526.7")
        RankingRow(
            title: "Tulsa",
            value: "402.1",
            ranking: 67,
            titleFont: .headline,
            rankingFont: .headline,
            inTableWithLongestValue: "526.7"
        )
        RankingRow(title: "Old Dominion", value: "98.2", ranking: 138, inTableWithLongestValue: "526.7")
        RankingRow(title: "Sacramento St.", ranking: nil, inTableWithLongestValue: "526.7")
    }
}
