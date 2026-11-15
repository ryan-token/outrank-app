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

    var body: some View {
        SidebarList(selection: selectedDetail) {
            PreferencesSection(selectedDetail: $selectedDetail)
            SupportSection(selectedDetail: $selectedDetail)
            GeneralSection(isShowingAbout: $isShowingAbout, rankingsLastUpdated: lastUpdated.date)
            #if DEBUG
            DebugSection()
            #endif
        }
        .refreshTask {
            await lastUpdated.loadIfStale()
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
