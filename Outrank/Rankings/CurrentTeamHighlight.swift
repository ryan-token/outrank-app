//
//  CurrentTeamHighlight.swift
//  Outrank
//

import SwiftUI

/// The fill behind the selected team's row in a stat's table of rankings: a wash of the
/// color its ranking is written in, the way the History chart shades the half of the field
/// a team is in. A band of color is what the eye catches as a long table scrolls by.
struct CurrentTeamHighlight: View {
    /// `nil` when the team has no ranking in the stat.
    let ranking: Int?

    var body: some View {
        Rectangle()
            .fill(RankingStyle.color(for: ranking).quaternary)
            // The wash goes over the row's own background, not in place of it.
            .background(.background.secondary)
    }
}

#Preview {
    List {
        RankingRow(title: "Memphis", value: "520.1", ranking: 3)
        RankingRow(title: "Tulsa", value: "402.1", ranking: 46, titleFont: .headline, rankingFont: .headline)
            .listRowBackground(CurrentTeamHighlight(ranking: 46))
        RankingRow(title: "Rice", value: "301.9", ranking: 120, titleFont: .headline, rankingFont: .headline)
            .listRowBackground(CurrentTeamHighlight(ranking: 120))
        RankingRow(title: "Sacramento St.", ranking: nil, titleFont: .headline, rankingFont: .headline)
            .listRowBackground(CurrentTeamHighlight(ranking: nil))
    }
}
