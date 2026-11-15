//
//  SubscriptionStatusCard.swift
//  Outrank
//

import SwiftUI

/// A card for a subscriber: a thank-you with the plan and its next date, or what to do
/// when billing needs attention.
struct SubscriptionStatusCard: View {
    let summary: SubscriptionStatusSummary

    var body: some View {
        GroupBox {
            HStack {
                Image(systemName: summary.needsAttention ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                    .font(.title)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)

                VStack(alignment: .leading) {
                    Text(summary.title)
                        .font(.headline)

                    Text(summary.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        // A light wash of the tint in place of the usual gray: the app's green for a
        // subscription in good standing, orange when billing needs attention.
        .backgroundStyle(.tint.opacity(0.12))
        .tint(summary.needsAttention ? .orange : nil)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Subscribed") {
    if let summary = SubscriptionStatusSummary(
        state: .subscribed,
        productID: "yearly",
        productNames: ["yearly": "Outrank Yearly"],
        expirationDate: .now.addingTimeInterval(86_400 * 200)
    ) {
        SubscriptionStatusCard(summary: summary)
            .padding()
    }
}

#Preview("Billing issue") {
    if let summary = SubscriptionStatusSummary(
        state: .inBillingRetryPeriod, productID: "yearly", productNames: ["yearly": "Outrank Yearly"]
    ) {
        SubscriptionStatusCard(summary: summary)
            .padding()
    }
}

#Preview("Unverified") {
    SubscriptionStatusCard(summary: .unverified)
        .padding()
}
