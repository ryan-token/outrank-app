//
//  RankingsSidebar.swift
//  Outrank
//
//  Created by Ryan Token on 10/2/21.
//

import SwiftUI

/// The selected team's ranking in every stat. Selecting a stat shows every team's
/// ranking in it: beside this list in regular widths, pushed in compact ones.
struct RankingsSidebar: View {
    @Bindable var model: TeamRankingsModel
    @Binding var selectedStat: String?
    @Binding var isShowingTeamPicker: Bool
    @Binding var isShowingInfoSheet: Bool

    @Environment(\.splitViewIsCollapsed) private var splitViewIsCollapsed

    var body: some View {
        // The list only shows the selection, as the highlighted row beside the stat's
        // screen in two columns. Its rows set it. See `SidebarRow`. Collapsed, the list
        // gets no selection at all: a split view also navigates on its sidebar list's
        // selection, which would compete with the push the rows already cause.
        List(selection: .constant(splitViewIsCollapsed ? nil : selectedStat)) {
            Section {
                ForEach(model.sortedRankings) { entry in
                    SidebarRow(value: entry.id, selection: $selectedStat) {
                        RankingRow(title: entry.title, ranking: entry.ranking, titleFont: .headline)
                    }
                }

                if model.loadFailed {
                    Text("😕 Error loading rankings for \(model.team). Please try again or try a different team.")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Sorted by \(model.sortMethod.sectionLabel())")
            }
        }
        .refreshable {
            await model.load()
        }
        .animation(.default, value: model.revision)
        .navigationTitle(model.team)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            // Each item has a symbol as well as a title, so on iPhone Duo it can move
            // into the vertical bar instead of holding a horizontal bar open.
            ToolbarItem(placement: .topBarLeading) {
                Button("Choose Team", systemImage: "american.football", action: showTeamPicker)
                    .tint(.primary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Info", systemImage: "info.circle", action: showInfoSheet)
                    .tint(.primary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                SortMenu(sortMethod: $model.sortMethod)
                    .tint(.primary)
            }
        }
    }

    private func showTeamPicker() {
        isShowingTeamPicker = true
    }

    private func showInfoSheet() {
        isShowingInfoSheet = true
    }
}
