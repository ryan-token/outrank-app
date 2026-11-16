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

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Where the table's headings and rows are on screen, across it. Every row says, so
    /// it is still known, and still right after the screen turns, far down the table.
    @State private var tableSpan = HorizontalSpan()

    /// Whether the table's headings have scrolled up past the place of their pinned copy.
    @State private var headerPin = RankingTableHeaderPin()

    /// The room between a heading and the text under it, the same in each section that
    /// has both.
    @ScaledMetric private var headingSpacing = 8.0

    private var humanReadableStat: String {
        Conversions.humanReadableStat(for: stat)
    }

    /// At accessibility text sizes each row stacks its numbers under the team's name,
    /// which leaves no columns to head.
    private var showsTableHeader: Bool {
        !model.entries.isEmpty && !dynamicTypeSize.isAccessibilitySize
    }

    var body: some View {
        let valueColumn = RankingValueColumn(stat: stat, longestValue: model.longestValue)

        List {
            Section {
                // One row: the sentence spells out the ranking above it.
                VStack(alignment: .leading, spacing: headingSpacing) {
                    RankingRow(
                        title: String(localized: "\(team)'s ranking"),
                        ranking: ranking,
                        titleFont: .headline,
                        rankingFont: .headline
                    )

                    if let ranking {
                        RankingSentence(
                            team: team,
                            stat: humanReadableStat,
                            ranking: ranking,
                            value: value,
                            valueFormat: AllStats.valueFormat(for: stat)
                        )
                    }
                }
            }

            Section {
                // One row, laid out like the one above: a heading is set apart from what
                // it heads by its weight, without a line.
                VStack(alignment: .leading, spacing: headingSpacing) {
                    Text("Description:")
                        .font(.headline)

                    Text(AllStats.description(for: stat))
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Text("All rankings for this stat:")
                    .font(.headline)
                    .listRowSeparator(.hidden, edges: .bottom)

                if showsTableHeader {
                    RankingTableHeader(valueColumn: valueColumn)
                        .onHorizontalSpanChange { tableSpan = $0 }
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.frame(in: .global).minY
                        } action: { minY in
                            headerPin.headingsMoved(to: minY)
                        }
                        .onDisappear {
                            headerPin.headingsLeftScreen()
                        }
                }

                ForEach(model.entries) { entry in
                    let isCurrentTeam = entry.title == team
                    RankingRow(
                        title: entry.title,
                        value: entry.value,
                        ranking: entry.ranking,
                        titleFont: isCurrentTeam ? .headline : .body,
                        rankingFont: isCurrentTeam ? .headline : .body,
                        inTableWith: valueColumn
                    )
                    // Bold alone is easy to scroll past in a table this long.
                    .listRowBackground(isCurrentTeam ? CurrentTeamHighlight(ranking: entry.ranking) : nil)
                    .onHorizontalSpanChange { tableSpan = $0 }
                }

                if model.loadFailed {
                    RankingsLoadFailedRow(stat: humanReadableStat, reloadAttempt: $reloadAttempt)
                }
            }
        }
        .animation(.default, value: model.revision)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, contentOffset in
            headerPin.listScrolled(to: contentOffset)
        }
        .overlay(alignment: .top) {
            if showsTableHeader {
                PinnedRankingTableHeader(
                    valueColumn: valueColumn,
                    headingsMinX: tableSpan.minX,
                    headingsWidth: tableSpan.width,
                    isPinned: headerPin.isPinned,
                    headingsMinY: $headerPin.pinLine
                )
            }
        }
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
