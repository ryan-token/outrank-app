//
//  RankingDetailView.swift
//  Outrank
//
//  Created by Ryan Token on 10/4/21.
//

import SwiftUI

/// Every team's ranking and value in one stat, with the selected team highlighted.
struct RankingDetailView: View {
    let team: String
    let stat: String

    /// `nil` when the team has no ranking in the stat.
    let ranking: Int?

    /// The team's value in the stat, formatted for display. `nil` when it has none.
    let value: String?

    @State private var model = StatRankingsModel()
    @State private var reloadAttempt = 0

    private var humanReadableStat: String {
        Conversions.humanReadableStat(for: stat)
    }

    var body: some View {
        List {
            Section {
                RankingRow(
                    title: String(localized: "\(team)'s Ranking"),
                    value: value,
                    ranking: ranking,
                    titleFont: .headline,
                    rankingFont: .headline
                )
            }

            Section {
                Text("Description:")
                    .font(.headline)

                Text(AllStats.description(for: stat))
                    .foregroundStyle(.secondary)
            }

            Section {
                Text("All Rankings For This Stat:")
                    .font(.headline)

                ForEach(model.entries) { entry in
                    let isCurrentTeam = entry.title == team
                    RankingRow(
                        title: entry.title,
                        value: entry.value,
                        ranking: entry.ranking,
                        titleFont: isCurrentTeam ? .headline : .body,
                        rankingFont: isCurrentTeam ? .headline : .body
                    )
                }

                if model.loadFailed {
                    RankingsLoadFailedRow(stat: humanReadableStat, reloadAttempt: $reloadAttempt)
                }
            }
        }
        .animation(.default, value: model.revision)
        .navigationTitle(humanReadableStat)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await model.load(stat: stat)
        }
        // Keyed on the retry counter, so tapping "Try Again" restarts a task SwiftUI still
        // owns and cancels, rather than an unstructured one. The stat itself never changes
        // for this view: `RankingsDetailDestination` gives each stat its own identity with `.id`.
        .refreshTask(id: reloadAttempt) {
            await model.loadIfStale(stat: stat)
        }
    }
}

#Preview {
    NavigationStack {
        RankingDetailView(team: "Tulsa", stat: "FewestPenaltyYardsPerGame", ranking: 19, value: "43.10")
    }
}
