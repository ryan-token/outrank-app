//
//  RankingTableCell.swift
//  Outrank
//

import SwiftUI

/// One row's place in a column of a stat's table of rankings.
///
/// Rows of a list are laid out one at a time, so nothing lines their columns up for them.
/// Instead every cell of a column is as wide as the widest thing the column can hold: its
/// heading, and its longest entry in the heaviest font a row uses. The heading is a cell
/// too, which is what keeps it over its column.
struct RankingTableCell<Content: View>: View {
    let column: RankingTableColumn
    @ViewBuilder var content: Content

    /// Last place in the FBS field, the ranking with the most digits.
    private static var longestRanking: String {
        Conversions.humanReadableRanking(for: AllTeams.all.count)
    }

    var body: some View {
        ZStack(alignment: column.alignment) {
            Group {
                Text(column.title)
                    .font(RankingTableColumn.headingFont)

                // The selected team's row is set in the headline font, the widest there is.
                Group {
                    switch column {
                    case .value(let longest):
                        StatValueBadge(value: longest)
                    case .ranking:
                        Text(Self.longestRanking)
                            .monospacedDigit()
                    }
                }
                .font(.headline)
            }
            .hidden()

            content
        }
    }
}

extension RankingTableCell where Content == Text {
    /// The heading over a column.
    init(heading column: RankingTableColumn) {
        self.init(column: column) {
            Text(column.title)
        }
    }
}
