//
//  RankingRow.swift
//  Outrank
//
//  Created by Ryan Token on 10/2/21.
//

import SwiftUI

/// A name with a ranking on the trailing edge: a stat with the selected team's ranking,
/// or a team with its ranking in one stat and, before it, the value that earned it.
struct RankingRow: View {
    let title: String

    /// The stat value behind the ranking, already formatted. `nil` for a row with none
    /// to show.
    var value: String?

    /// `nil` when the team has no ranking in the stat.
    let ranking: Int?
    var titleFont: Font = .body
    var rankingFont: Font = .body

    /// The column of values in the table of rankings this row is part of, which lines the
    /// row's value and ranking up with the rows around it and the headings above them.
    /// `nil` for a row that stands alone, or whose table has no values.
    var inTableWith: RankingValueColumn?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.backgroundProminence) private var backgroundProminence

    var body: some View {
        // A long name wraps beside the ranking, keeping every ranking on the trailing
        // edge so they line up down the list. At accessibility text sizes there isn't
        // room for both, so the ranking moves under the name.
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())
        // Stacked under the name there are no columns to keep to.
        let valueColumn = dynamicTypeSize.isAccessibilitySize ? nil : inTableWith
        let rankingText = Text(Conversions.humanReadableRanking(for: ranking))
            // Digits of one width, so last place really is the widest ranking in a table.
            .monospacedDigit()
            // On a selected row's filled background the ranking color would blend in, so
            // it matches the row's white text instead.
            .foregroundStyle(backgroundProminence == .increased ? .white : RankingStyle.color(for: ranking))

        layout {
            Text(title)
                .font(titleFont)
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if let valueColumn {
                    // A team with no value still takes its place in the column, so its
                    // ranking stays under the right heading.
                    RankingTableCell(column: .value(valueColumn)) {
                        if let value {
                            StatValueText(value: value)
                        }
                    }

                    RankingTableCell(column: .ranking) {
                        rankingText
                    }
                } else {
                    if let value {
                        StatValueText(value: value)
                    }

                    rankingText
                }
            }
            .font(rankingFont)
            // Take their full width first, so the name is what wraps.
            .layoutPriority(1)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        List {
            NavigationLink(value: "Long") {
                RankingRow(title: "Third Down Conversion Pct Defense", ranking: 98, titleFont: .headline)
            }

            NavigationLink(value: "Short") {
                RankingRow(title: "Passing Offense", ranking: 97, titleFont: .headline)
            }

            NavigationLink(value: "Unranked") {
                RankingRow(title: "Blocked Kicks", ranking: nil, titleFont: .headline)
            }
        }
    }
}

#Preview("Values") {
    List {
        RankingRow(title: "Oklahoma St.", value: "526.7", ranking: 1)
        RankingRow(title: "Tulsa", value: "402.1", ranking: 67, titleFont: .headline, rankingFont: .headline)
        RankingRow(title: "Old Dominion", value: "268.2", ranking: 138)
        RankingRow(title: "Sacramento St.", ranking: nil)
    }
}
