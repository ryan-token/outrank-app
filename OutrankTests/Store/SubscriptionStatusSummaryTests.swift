//
//  SubscriptionStatusSummaryTests.swift
//  OutrankTests
//

import Foundation
import StoreKit
import Testing
@testable import Outrank

struct SubscriptionStatusSummaryTests {
    private let date = Date(timeIntervalSince1970: 1_800_000_000)
    private let names = ["monthly": "Monthly", "yearly": "Yearly"]

    private var formattedDate: String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    private func summary(
        _ state: Product.SubscriptionInfo.RenewalState = .subscribed,
        productID: String = "yearly",
        expirationDate: Date? = nil,
        willAutoRenew: Bool = true,
        autoRenewPreference: String? = nil,
        gracePeriodExpirationDate: Date? = nil
    ) -> SubscriptionStatusSummary? {
        SubscriptionStatusSummary(
            state: state,
            productID: productID,
            productNames: names,
            expirationDate: expirationDate,
            willAutoRenew: willAutoRenew,
            autoRenewPreference: autoRenewPreference,
            gracePeriodExpirationDate: gracePeriodExpirationDate
        )
    }

    @Test func renewingSubscriptionThanksTheUserAndShowsTheRenewalDate() throws {
        let summary = try #require(summary(expirationDate: date, autoRenewPreference: "yearly"))

        #expect(summary.title == "Thank you for subscribing")
        #expect(summary.detail == "Yearly · Renews \(formattedDate)")
        #expect(!summary.needsAttention)
    }

    @Test func cancelledSubscriptionShowsWhenItEnds() {
        let summary = summary(expirationDate: date, willAutoRenew: false)

        #expect(summary?.detail == "Yearly · Ends \(formattedDate)")
    }

    @Test func switchedSubscriptionShowsWhatComesNext() {
        let summary = summary(productID: "monthly", expirationDate: date, autoRenewPreference: "yearly")

        #expect(summary?.detail == "Monthly · Switches to Yearly on \(formattedDate)")
    }

    /// A cancelled subscription keeps the preference it had, but nothing comes next.
    @Test func cancelledSwitchShowsWhenItEnds() {
        let summary = summary(
            productID: "monthly", expirationDate: date, willAutoRenew: false, autoRenewPreference: "yearly"
        )

        #expect(summary?.detail == "Monthly · Ends \(formattedDate)")
    }

    @Test func subscriptionWithoutADateShowsOnlyThePlan() {
        #expect(summary()?.detail == "Yearly")
    }

    @Test func gracePeriodAsksForPaymentDetailsByItsEnd() throws {
        let summary = try #require(summary(.inGracePeriod, expirationDate: date, gracePeriodExpirationDate: date))

        #expect(summary.title == "Billing Issue")
        #expect(summary.detail == "Update your payment details by \(formattedDate) to keep Yearly.")
        #expect(summary.needsAttention)
    }

    @Test func billingRetryNeedsAttention() throws {
        let summary = try #require(summary(.inBillingRetryPeriod))

        #expect(summary.detail == "Update your payment details to resume Yearly.")
        #expect(summary.needsAttention)
    }

    @Test(arguments: [Product.SubscriptionInfo.RenewalState.expired, .revoked])
    func endedSubscriptionHasNoSummary(state: Product.SubscriptionInfo.RenewalState) {
        #expect(summary(state, expirationDate: date) == nil)
    }
}
