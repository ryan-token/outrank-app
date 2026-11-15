//
//  GeneralSection.swift
//  Outrank
//
//  Created by Ryan Token on 10/5/21.
//

import SwiftUI

struct GeneralSection: View {
    @Binding var isShowingAbout: Bool

    /// When the backend last refreshed the rankings; `nil` until Settings has loaded it.
    let rankingsLastUpdated: Date?

    private static let lastUpdatedFormat = Date.FormatStyle.dateTime
        .weekday(.abbreviated)
        .month(.abbreviated)
        .day()
        .hour()
        .minute()

    @Environment(\.openURL) private var openURL
    @State private var isShowingPrivacyDialog = false

    var body: some View {
        Section {
            Link(destination: AppLinks.featureRequest) {
                SettingsRow(
                    icon: "bolt",
                    iconColor: .mint,
                    title: "Feature Request",
                    showsExternalIndicator: true
                )
            }
            .accessibilityLabel("Send an email with a feature request")

            Button(action: showAbout) {
                SettingsRow(icon: "person", iconColor: .blue, title: "About")
            }

            Button(action: showPrivacyDialog) {
                SettingsRow(icon: "lock", iconColor: .gray, title: "Terms & Privacy Policy")
            }
            .accessibilityLabel("Terms of Use and Privacy Policy")
            .confirmationDialog(
                "Terms of Use and Privacy Policy",
                isPresented: $isShowingPrivacyDialog,
                titleVisibility: .visible
            ) {
                Button("Terms of Use", action: openTermsOfUse)
                Button("Privacy Policy", action: openPrivacyPolicy)
            }
        } header: {
            Text("General")
        } footer: {
            if let rankingsLastUpdated {
                Text("Rankings last updated \(rankingsLastUpdated, format: Self.lastUpdatedFormat)")
            }
        }
    }

    private func showAbout() {
        isShowingAbout = true
    }

    private func showPrivacyDialog() {
        isShowingPrivacyDialog = true
    }

    private func openTermsOfUse() {
        openURL(AppLinks.termsOfUse)
    }

    private func openPrivacyPolicy() {
        openURL(AppLinks.privacyPolicy)
    }
}
