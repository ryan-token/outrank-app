//
//  CurrentTeamHighlight.swift
//  Outrank
//

import SwiftUI

/// Goes behind the selected team's row in a stat's table of rankings: a rounded wash of
/// the color its ranking is written in, the way the History chart shades the half of the
/// field a team is in. A band of color is what the eye catches as a long table scrolls by.
///
/// It is the background of the row's contents rather than of the row, so it reaches a
/// little past the text on every side and stops short of the lines between rows.
struct CurrentTeamHighlight: View {
    /// `nil` when the team has no ranking in the stat.
    let ranking: Int?

    /// How far the wash reaches past the row's contents.
    @ScaledMetric private var horizontalOutset = 8.0
    @ScaledMetric private var verticalOutset = 7.0

    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(RankingStyle.color(for: ranking).quaternary)
            .padding(.horizontal, -horizontalOutset)
            .padding(.vertical, -verticalOutset)
    }
}

#Preview {
    List {
        RankingRow(title: "Memphis", value: "520.1", ranking: 3)
        RankingRow(title: "Tulsa", value: "402.1", ranking: 46, titleFont: .headline, rankingFont: .headline)
            .background(CurrentTeamHighlight(ranking: 46))
        RankingRow(title: "Rice", value: "301.9", ranking: 120, titleFont: .headline, rankingFont: .headline)
            .background(CurrentTeamHighlight(ranking: 120))
        RankingRow(title: "Sacramento St.", ranking: nil, titleFont: .headline, rankingFont: .headline)
            .background(CurrentTeamHighlight(ranking: nil))
    }
}
