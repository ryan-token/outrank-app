//
//  SupportSection.swift
//  Outrank
//
//  Created by Ryan Token on 10/5/21.
//

import SwiftUI

struct SupportSection: View {
    @Binding var selectedDetail: SettingsDetail?

    var body: some View {
        Section("Support") {
            Link(destination: AppLinks.writeReview) {
                SettingsRow(
                    icon: "heart",
                    iconColor: .red,
                    title: "Rate",
                    showsExternalIndicator: true
                )
            }

            SidebarRow(value: .tipJar, selection: $selectedDetail) {
                SettingsRow(icon: "centsign", iconColor: .orange, title: "Leave a Tip")
            }

            SidebarRow(value: .subscriptions, selection: $selectedDetail) {
                SettingsRow(icon: "dollarsign", iconColor: .green, title: "Subscribe")
            }
        }
    }
}
