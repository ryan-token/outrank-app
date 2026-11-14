//
//  SettingsSidebar.swift
//  Outrank
//
//  Created by Ryan Token on 10/5/21.
//

import SwiftUI

struct SettingsSidebar: View {
    @Binding var selectedDetail: SettingsDetail?

    @State private var isShowingAbout = false
    @State private var lastUpdated = LastUpdatedModel()

    @Environment(\.splitViewIsCollapsed) private var splitViewIsCollapsed

    var body: some View {
        // The list only shows the selection, and only in two columns; its rows set it.
        // See `SidebarRow` and `RankingsSidebar`.
        List(selection: .constant(splitViewIsCollapsed ? nil : selectedDetail)) {
            PreferencesSection(selectedDetail: $selectedDetail)
            SupportSection(selectedDetail: $selectedDetail)
            GeneralSection(isShowingAbout: $isShowingAbout, rankingsLastUpdated: lastUpdated.date)
            #if DEBUG
            DebugSection()
            #endif
        }
        .refreshTask {
            await lastUpdated.load()
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        // Presented from the list rather than its row, so the sheet doesn't depend on a
        // lazily created row staying alive.
        .sheet(isPresented: $isShowingAbout) {
            AboutView()
        }
    }
}
