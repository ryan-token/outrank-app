//
//  SettingsView.swift
//  Outrank
//
//  Created by Ryan Token on 10/5/21.
//

import SwiftUI

struct SettingsView: View {
    /// Owned by the window, so other screens can open a settings page directly.
    @Binding var selectedDetail: SettingsDetail?

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        // One split view at every size: it collapses to a stack in compact widths and
        // keeps `selectedDetail` across folds, rotations, and window resizes.
        NavigationSplitView {
            SettingsSidebar(selectedDetail: $selectedDetail)
                // A destination, not a switch inside the detail column, so each page's title
                // is known before it is pushed in compact widths. See `RankingsView`.
                .navigationDestination(item: $selectedDetail) { detail in
                    SettingsDetailPage(detail: detail)
                }
        } detail: {
            // Shown until a page is selected, where there is room for a second column.
            WelcomeView(type: .settings)
        }
        .environment(\.splitViewIsCollapsed, horizontalSizeClass == .compact)
    }
}

#Preview {
    @Previewable @State var selectedDetail: SettingsDetail?

    SettingsView(selectedDetail: $selectedDetail)
        .environment(Store())
        .environment(\.managedObjectContext, PersistentContainer.preview.viewContext)
}
