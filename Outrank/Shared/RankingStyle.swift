//
//  RankingStyle.swift
//  Outrank
//
//  Created by Ryan Token on 9/4/26.
//

import SwiftUI

/// Styling rules shared by every view that shows a team's ranking in a stat.
nonisolated enum RankingStyle {
    /// A ranking in the better half of the FBS field reads as good. Derived from
    /// the team list so it stays correct as programs join or leave FBS.
    static let goodRankingCutoff = AllTeams.all.count / 2

    /// Green for the better half of the field, red for the worse half, and a
    /// neutral tint for teams with no ranking — an unranked team has not played
    /// badly, it has no result at all.
    static func color(for ranking: Int?) -> Color {
        guard let ranking else { return .secondary }
        return ranking <= goodRankingCutoff ? .green : .red
    }

    /// A fill for a ranking scale drawn with 1st at the top: green for the better half of
    /// the field and red for the worse half, the same split `color(for:)` makes.
    /// - Parameter topHalfFraction: How far down the scale the better half reaches, from
    ///   0 at the top to 1 at the bottom.
    static func scaleGradient(topHalfFraction: Double) -> LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: .green, location: 0),
                Gradient.Stop(color: .green, location: topHalfFraction),
                Gradient.Stop(color: .red, location: topHalfFraction),
                Gradient.Stop(color: .red, location: 1)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Green when `ranking` beats `other`, red when it trails, yellow when they tie.
    /// A team with no ranking in the stat has not lost the comparison, so it gets a
    /// neutral tint rather than being colored as the worse of the two.
    static func comparisonColor(for ranking: Int?, comparedTo other: Int?) -> Color {
        guard let ranking else { return .secondary }
        // Having a ranking at all beats having none.
        guard let other else { return .green }

        return if ranking < other {
            .green
        } else if ranking > other {
            .red
        } else {
            .yellow
        }
    }
}
