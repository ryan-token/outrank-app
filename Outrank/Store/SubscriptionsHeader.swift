//
//  SubscriptionsHeader.swift
//  Outrank
//

import StoreKit
import SwiftUI

/// What sits above the subscription options in Settings: what a subscription is for, and
/// where the user's own subscription stands when they have one.
struct SubscriptionsHeader: View {
    /// The subscription the user holds and its status, or `nil` without one.
    let currentSubscription: Product?
    let status: Product.SubscriptionInfo.Status?

    var body: some View {
        VStack {
            Image(systemName: "heart.fill")
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Support Outrank")
                .font(.title)
                .bold()

            Text("""
                Outrank is free with no ads. Every option supports development and unlocks \
                History, which charts a team's ranking in any stat across a season.
                """)

            if let currentSubscription, let status {
                StatusInfoView(product: currentSubscription, status: status)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    SubscriptionsHeader(currentSubscription: nil, status: nil)
}
