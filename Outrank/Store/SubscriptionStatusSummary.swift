//
//  SubscriptionStatusSummary.swift
//  Outrank
//

import Foundation
import StoreKit

/// Where the user's subscription stands, in the few words the Subscriptions screen shows.
struct SubscriptionStatusSummary: Equatable {
    let title: String
    let detail: String

    /// Whether billing needs the user's attention. Otherwise the subscription is in good
    /// standing and the summary is a thank-you.
    let needsAttention: Bool

    /// What to show when the App Store can't vouch for the subscription it reports.
    static let unverified = SubscriptionStatusSummary(
        title: "Subscription Unverified",
        detail: "The App Store could not verify your subscription status.",
        needsAttention: true
    )

    private init(title: String, detail: String, needsAttention: Bool) {
        self.title = title
        self.detail = detail
        self.needsAttention = needsAttention
    }

    /// Returns `nil` for a subscription that has expired or been refunded, which leaves
    /// nothing to thank the user for or to fix.
    ///
    /// - Parameters:
    ///   - state: The subscription's renewal state.
    ///   - productID: The subscription the user holds.
    ///   - productNames: The display name of every subscription, by product ID.
    ///   - expirationDate: When the current period ends.
    ///   - willAutoRenew: Whether the subscription renews at the end of the period.
    ///   - autoRenewPreference: The subscription that the next period renews as.
    ///   - gracePeriodExpirationDate: When a billing grace period ends.
    init?(
        state: Product.SubscriptionInfo.RenewalState,
        productID: String,
        productNames: [String: String],
        expirationDate: Date? = nil,
        willAutoRenew: Bool = true,
        autoRenewPreference: String? = nil,
        gracePeriodExpirationDate: Date? = nil
    ) {
        let productName = productNames[productID] ?? ""

        switch state {
        case .expired, .revoked:
            return nil
        case .inGracePeriod:
            title = "Billing Issue"
            if let gracePeriodExpirationDate {
                let date = Self.formatted(gracePeriodExpirationDate)
                detail = "Update your payment details by \(date) to keep \(productName)."
            } else {
                detail = "Update your payment details to keep \(productName)."
            }
            needsAttention = true
        case .inBillingRetryPeriod:
            title = "Billing Issue"
            detail = "Update your payment details to resume \(productName)."
            needsAttention = true
        default:
            title = "Thank you for subscribing"
            needsAttention = false

            guard let expirationDate else {
                detail = productName
                return
            }

            // Only a switch to a different subscription is worth naming, and only
            // while the subscription still renews: a cancelled one keeps its preference.
            let upcomingProductName = autoRenewPreference == productID
                ? nil
                : autoRenewPreference.flatMap { productNames[$0] }

            let date = Self.formatted(expirationDate)
            if !willAutoRenew {
                detail = "\(productName) · Ends \(date)"
            } else if let upcomingProductName {
                detail = "\(productName) · Switches to \(upcomingProductName) on \(date)"
            } else {
                detail = "\(productName) · Renews \(date)"
            }
        }
    }

    private static func formatted(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
