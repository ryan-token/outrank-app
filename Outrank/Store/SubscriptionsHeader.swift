//
//  SubscriptionsHeader.swift
//  Outrank
//

import StoreKit
import SwiftUI

/// What sits above the subscription options in Settings: what a subscription is for, and
/// where the user's own subscription stands when they have one.
struct SubscriptionsHeader: View {
    @Environment(Store.self) private var store

    /// The subscription the user holds and its status, or `nil` without one.
    let currentSubscription: Product?
    let status: Product.SubscriptionInfo.Status?

    /// The subscriber's summary, or `nil` without a subscription to show.
    private var summary: SubscriptionStatusSummary? {
        guard let currentSubscription, let status else {
            return nil
        }

        guard case .verified(let renewalInfo) = status.renewalInfo,
              case .verified(let transaction) = status.transaction else {
            return .unverified
        }

        return SubscriptionStatusSummary(
            state: status.state,
            productID: currentSubscription.id,
            productNames: Dictionary(
                store.subscriptions.map { ($0.id, $0.displayName) },
                uniquingKeysWith: { first, _ in first }
            ),
            expirationDate: transaction.expirationDate,
            willAutoRenew: renewalInfo.willAutoRenew,
            autoRenewPreference: renewalInfo.autoRenewPreference,
            gracePeriodExpirationDate: renewalInfo.gracePeriodExpirationDate
        )
    }

    var body: some View {
        VStack {
            Image(systemName: "heart.fill")
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Support Outrank")
                .font(.title)
                .bold()

            Text("Free, with no ads. Subscribing supports development and unlocks History charts.")
                .foregroundStyle(.secondary)

            if let summary {
                SubscriptionStatusCard(summary: summary)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

#Preview {
    SubscriptionsHeader(currentSubscription: nil, status: nil)
        .environment(Store())
}
