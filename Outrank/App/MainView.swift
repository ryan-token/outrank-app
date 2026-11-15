//
//  MainView.swift
//  Outrank
//
//  Created by Ryan Token on 10/2/21.
//

import SwiftUI

struct MainView: View {
    // Each window has its own place while it is open, and starts at the last one saved.
    @State private var activeTab = LastPlace.tab
    @State private var settingsDetail: SettingsDetail?

    @State private var router = WindowRouter()

    var body: some View {
        TabView(selection: $activeTab) {
            Tab("Rankings", systemImage: "list.bullet.rectangle.portrait", value: .rankings) {
                RankingsView()
            }

            Tab("Compare", systemImage: "eyeglasses", value: .compare) {
                ComparisonView()
            }

            Tab("History", systemImage: "chart.line.uptrend.xyaxis", value: .history) {
                HistoryView()
            }

            Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsView(selectedDetail: $settingsDetail)
            }
        }
        .environment(router)
        .onChange(of: activeTab) { LastPlace.tab = activeTab }
        .onChange(of: settingsDetail) { LastPlace.settingsDetail = settingsDetail }
        // The selection is this window's own state, so the window applies each request here.
        .onChange(of: router.requestedSettingsDetail) { _, detail in
            guard let detail else { return }
            activeTab = .settings
            settingsDetail = detail
            router.clearRequest()
        }
        .onAppear {
            // Set once the tab is on screen: a split view doesn't present a destination
            // whose item is already set when it first appears.
            if activeTab == .settings {
                settingsDetail = LastPlace.settingsDetail
            } else {
                // The page is only saved when it changes, so one left open behind another
                // tab would otherwise come back the next time the app launches into Settings.
                LastPlace.settingsDetail = nil
            }

            #if DEBUG
            if let tab = ScreenshotMode.tab {
                activeTab = tab
            }
            #endif
        }
    }
}

#Preview {
    MainView()
        .environment(Store())
        .environment(\.managedObjectContext, PersistentContainer.preview.viewContext)
}
