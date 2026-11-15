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

    /// Last place in the FBS field, the ranking with the most digits.
    private static let longestRanking = Conversions.humanReadableRanking(for: AllTeams.all.count)

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.backgroundProminence) private var backgroundProminence

    var body: some View {
        // A long name wraps beside the ranking, keeping every ranking on the trailing
        // edge so they line up down the list. At accessibility text sizes there isn't
        // room for both, so the ranking moves under the name.
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading))
            : AnyLayout(HStackLayout())

        layout {
            Text(title)
                .font(titleFont)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let value {
                Text(value)
                    .font(rankingFont)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .layoutPriority(1)
            }

            ZStack(alignment: .trailing) {
                // Beside a value, every ranking takes the room of the longest one, so the
                // values line up down the list as the rankings do.
                if value != nil, !dynamicTypeSize.isAccessibilitySize {
                    Text(Self.longestRanking)
                        .hidden()
                }

                Text(Conversions.humanReadableRanking(for: ranking))
                    // On a selected row's filled background the ranking color would blend
                    // in, so it matches the row's white text instead.
                    .foregroundStyle(backgroundProminence == .increased ? .white : RankingStyle.color(for: ranking))
            }
            .font(rankingFont)
            // Digits of one width, so "138th" really is the widest ranking there is.
            .monospacedDigit()
            // Takes its full width first, so the name is what wraps.
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
