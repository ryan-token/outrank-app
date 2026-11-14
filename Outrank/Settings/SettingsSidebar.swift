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

    var body: some View {
        // The list only shows the selection; its rows set it. See `SidebarRow`.
        List(selection: .constant(selectedDetail)) {
            PreferencesSection(selectedDetail: $selectedDetail)
            SupportSection(selectedDetail: $selectedDetail)
            GeneralSection(isShowingAbout: $isShowingAbout)
            #if DEBUG
            DebugSection()
            #endif
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
