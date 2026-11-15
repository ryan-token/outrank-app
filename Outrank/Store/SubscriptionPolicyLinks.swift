//
//  SubscriptionPolicyLinks.swift
//  Outrank
//

import SwiftUI

/// The terms and privacy policy links shown with the subscription options. They open the
/// same pages as the Terms & Privacy Policy row in Settings.
///
/// These stand in for StoreKit's own policy buttons, which present the page in a sheet.
/// That sheet never appears when the subscription options are pushed inside the Settings
/// split view, so the buttons did nothing there.
struct SubscriptionPolicyLinks: View {
    var body: some View {
        ViewThatFits {
            HStack {
                SubscriptionPolicyLinksContent()
            }

            // Larger text sizes don't fit on one line.
            VStack {
                SubscriptionPolicyLinksContent()
            }
        }
        .font(.footnote)
        // The subscription store gives buttons in its header its own prominent style.
        .buttonStyle(.plain)
    }
}

#Preview {
    SubscriptionPolicyLinks()
}
