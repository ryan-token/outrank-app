//
//  SettingsDetailPage.swift
//  Outrank
//

import SwiftUI

/// The settings page selected in the sidebar.
struct SettingsDetailPage: View {
    let detail: SettingsDetail

    var body: some View {
        switch detail {
        case .favorites:
            MultiPickerView()
        case .tipJar:
            TipJarView()
        case .subscriptions:
            SubscriptionsView()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsDetailPage(detail: .tipJar)
            .environment(Store())
    }
}
