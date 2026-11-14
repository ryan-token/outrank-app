//
//  RankingsView.swift
//  Outrank
//
//  Created by Ryan Token on 10/2/21.
//

import StoreKit
import SwiftUI

struct RankingsView: View {
    @Environment(\.requestReview) private var requestReview
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("AppUsedCount") private var appUsedCount = 0
    @AppStorage("ReviewRequestedVersion") private var reviewRequestedVersion = ""

    @State private var model = TeamRankingsModel()
    @SceneStorage("SelectedStat") private var selectedStat: String?
    @State private var isShowingTeamPicker = false
    @State private var isShowingInfoSheet = false

    var body: some View {
        // One split view at every size. It collapses into a stack in compact widths and
        // expands into columns in regular ones, driven by `selectedStat` either way, so
        // folding iPhone Duo, rotating, or resizing an iPad window keeps the user's place.
        NavigationSplitView {
            RankingsSidebar(
                model: model,
                selectedStat: $selectedStat,
                isShowingTeamPicker: $isShowingTeamPicker,
                isShowingInfoSheet: $isShowingInfoSheet
            )
            // The selected stat is presented as a destination, not switched to inside the
            // detail column: a destination's title is known before it is pushed in compact
            // widths, where a column's own content only gets its title once the push ends.
            .navigationDestination(item: $selectedStat) { stat in
                RankingDetailView(team: model.team, stat: stat, ranking: model.ranking(forStat: stat))
                    // A new stat gets fresh state rather than briefly showing the last one's rankings.
                    .id(stat)
                    // Monochrome controls are tinted here and on the sidebar's toolbar items, not
                    // on the split view: its tint fills the selected sidebar row, and `.primary`
                    // is white in dark mode, which hid the row's white text.
                    .tint(.primary)
            }
        } detail: {
            // Shown until a stat is selected, where there is room for a second column.
            WelcomeView(type: .rankings)
        }
        .environment(\.splitViewIsCollapsed, horizontalSizeClass == .compact)
        .sheet(isPresented: $isShowingTeamPicker) {
            TeamPickerView(team: $model.team)
        }
        .sheet(isPresented: $isShowingInfoSheet) {
            InfoView(source: .rankings)
                .presentationDetents([.medium, .large])
        }
        .task(id: RankingsLoadKey(team: model.team, isActive: scenePhase == .active)) {
            guard scenePhase == .active else { return }
            await refreshRankings()
        }
        .onAppear {
            appUsedCount += 1

            #if DEBUG
            if let stat = ScreenshotMode.stat {
                selectedStat = stat
            }
            if ScreenshotMode.teamSearch != nil {
                isShowingTeamPicker = true
            }
            #endif
        }
    }

    /// Loads the team's rankings if they are missing or stale, then considers asking for
    /// a review once fresh rankings are on screen.
    private func refreshRankings() async {
        guard await model.loadIfStale(), appUsedCount > 5 else { return }

        #if DEBUG
        // Screenshots never show the review prompt.
        guard !ScreenshotMode.isEnabled else { return }
        #endif

        // Ask at most once per version; the system also limits how often the prompt shows.
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        guard version != reviewRequestedVersion else { return }
        reviewRequestedVersion = version
        requestReview()
    }
}

#Preview {
    RankingsView()
        .environment(WindowRouter())
        .environment(\.managedObjectContext, PersistentContainer.preview.viewContext)
}
