//
//  TopOrBottomFourView.swift
//  TopFourWidgetExtension
//
//  Created by Ryan Token on 10/9/21.
//

import SwiftUI
import WidgetKit

/// The medium widget: the team at the leading edge and its four best or worst stats beside
/// it, in white on a background that is green for the best and red for the worst.
struct TopOrBottomFourView: View {
    let type: WidgetType
    let team: String
    let rankings: [String: Int]

    @Environment(\.widgetRenderingMode) private var renderingMode

    /// How much of the widget's width the team's name takes.
    private static let teamFraction = 0.3

    /// The team's four best or worst ranked stats.
    private var rankedFour: [RankingEntry] {
        let ranked = rankings.map { stat, ranking in
            RankingEntry(id: stat, title: Conversions.humanReadableStat(for: stat), ranking: ranking)
        }

        return Array(type.sortMethod.sorted(ranked).prefix(4))
    }

    var body: some View {
        HStack(spacing: 0) {
            WidgetTeamPanel(type: type, team: team)
                .containerRelativeFrame(.horizontal) { width, _ in
                    width * Self.teamFraction
                }

            WidgetRankingList(entries: rankedFour)
        }
        // White on the colored background. In the tinted and clear styles the system removes
        // the background, so the text takes the color the system gives it.
        .foregroundStyle(renderingMode == .fullColor ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        .containerBackground(for: .widget) {
            WidgetBackdrop(type: type)
        }
    }
}

#Preview("Top Four", as: .systemMedium) {
    TopFourWidget()
} timeline: {
    TeamRankingsEntry(
        date: .now,
        team: "Tulsa",
        rankings: ["ScoringOffense": 3, "TotalOffense": 7, "RushingOffense": 11, "TurnoverMargin": 14]
    )
    TeamRankingsEntry(date: .now, team: "Southern California", rankings: [:])
}

#Preview("Bottom Four", as: .systemMedium) {
    BottomFourWidget()
} timeline: {
    TeamRankingsEntry(
        date: .now,
        team: "Army West Point",
        rankings: [
            "PassingYardsAllowed": 121, "ThirdDownConversionPctDefense": 124, "FewestPenalties": 128,
            "RedZoneDefense": 131
        ]
    )
}
