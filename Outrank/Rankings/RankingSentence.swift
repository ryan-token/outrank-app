//
//  RankingSentence.swift
//  Outrank
//

import SwiftUI

/// Says where a team ranks in a stat in so many words, with the value that put it there:
/// "Tulsa is 67th in the country in Total Offense with 402.1".
struct RankingSentence: View {
    let team: String

    /// The stat's readable name.
    let stat: String

    let ranking: Int

    /// The team's value in the stat, already formatted. `nil` when it has none.
    let value: String?

    // The badge in the sentence is padded as the badges in the table under it are.
    @ScaledMetric(relativeTo: .body) private var badgeHorizontalPadding = StatValueBadge.padding.width
    @ScaledMetric(relativeTo: .body) private var badgeVerticalPadding = StatValueBadge.padding.height

    var body: some View {
        let ranking = Conversions.humanReadableRanking(for: ranking)

        Group {
            if let value {
                Text("\(team) is \(ranking) in the country in \(stat) with \(StatValueBadge.inline(value))")
                    .textRenderer(StatValueBadgeRenderer(
                        padding: CGSize(width: badgeHorizontalPadding, height: badgeVerticalPadding)
                    ))
            } else {
                Text("\(team) is \(ranking) in the country in \(stat).")
            }
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    List {
        RankingSentence(team: "Tulsa", stat: "Total Offense", ranking: 67, value: "402.1")
        RankingSentence(team: "Tulsa", stat: "Time Of Possession", ranking: 121, value: "27.7 min")
        RankingSentence(team: "Tulsa", stat: "Total Offense", ranking: 67, value: nil)
    }
}
