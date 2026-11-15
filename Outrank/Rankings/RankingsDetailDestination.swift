//
//  RankingsDetailDestination.swift
//  Outrank
//

import SwiftUI

/// The selected stat's screen. A view of its own, so the team, its ranking and its value are read in a
/// body SwiftUI tracks: rankings can arrive after a restored selection is already on screen.
struct RankingsDetailDestination: View {
    let model: TeamRankingsModel
    let stat: String

    var body: some View {
        RankingDetailView(
            team: model.team,
            stat: stat,
            ranking: model.ranking(forStat: stat),
            value: model.value(forStat: stat)
        )
            // A new stat gets fresh state rather than briefly showing the last one's rankings.
            .id(stat)
    }
}
