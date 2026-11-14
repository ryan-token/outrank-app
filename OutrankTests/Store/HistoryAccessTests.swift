//
//  HistoryAccessTests.swift
//  OutrankTests
//

import Foundation
import Observation
import StoreKit
import StoreKitTest
import Testing
@testable import Outrank

/// History is included with every subscription and with nothing else. These run the real
/// `Store` against StoreKit's local test environment, using the app's own product
/// configuration, so they cover what the App Store would actually report.
///
/// The test environment's purchases are shared by the whole process, so the tests can't
/// run side by side. Every one of them waits on StoreKit, so each gets a time limit in
/// case StoreKit never answers.
@Suite(.serialized, .timeLimit(.minutes(1)))
struct HistoryAccessTests {
    enum Ending: CaseIterable {
        case expiry
        case refund
    }

    private let session: SKTestSession
    private let store: Store

    init() async throws {
        let configuration = try #require(Bundle.main.url(forResource: "Products", withExtension: "storekit"))
        session = try SKTestSession(contentsOf: configuration)
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true

        // The app hears of changes made through the session some time after they are
        // made. Syncing brings it up to date, so a purchase left by an earlier test is
        // gone before this one starts.
        try await AppStore.sync()

        store = Store()
        await store.requestProducts()
    }

    @Test func tipLeavesHistoryLocked() async throws {
        let tip = try #require(store.tips.first)

        _ = try #require(try await store.purchase(tip))

        #expect(store.subscriptionAccess == .notSubscribed)
    }

    @Test(arguments: Ending.allCases)
    func subscriptionUnlocksHistoryUntilItEnds(by ending: Ending) async throws {
        let subscription = try #require(store.subscriptions.first)

        let transaction = try #require(try await store.purchase(subscription))
        #expect(store.subscriptionAccess == .subscribed)

        switch ending {
        case .expiry:
            try session.expireSubscription(productIdentifier: subscription.id)
        case .refund:
            try session.refundTransaction(identifier: UInt(transaction.id))
        }
        // Syncing with the App Store, which here is the session, is what a restore does.
        try await AppStore.sync()
        await store.refreshEntitlements()

        #expect(store.subscriptionAccess == .notSubscribed)
    }

    // The History paywall is one of StoreKit's own views, so a purchase made there doesn't
    // go through `Store.purchase`. It reaches the store the way this one does, as a
    // transaction StoreKit reports some time later. A store that never picks it up runs
    // into the suite's time limit.
    @Test func purchaseMadeOutsideTheStoreUnlocksHistory() async throws {
        await store.refreshEntitlements()
        try #require(store.subscriptionAccess == .notSubscribed)

        try await session.buyProduct(identifier: #require(SubscriptionTier.productIDs.first))
        await accessBecomes(.subscribed)

        #expect(store.subscriptionAccess == .subscribed)
    }

    // Nothing tells the store to look again here. A subscription that lapses while the app
    // is running reaches it only as a change StoreKit reports once it has heard from the
    // App Store, which syncing stands in for.
    @Test func subscriptionThatLapsesWhileTheAppIsRunningLocksHistory() async throws {
        let subscription = try #require(store.subscriptions.first)
        _ = try #require(try await store.purchase(subscription))
        try #require(store.subscriptionAccess == .subscribed)

        try session.expireSubscription(productIdentifier: subscription.id)
        try await AppStore.sync()
        await accessBecomes(.notSubscribed)

        #expect(store.subscriptionAccess == .notSubscribed)
    }

    /// Suspends until the store reports `access`.
    private func accessBecomes(_ access: SubscriptionAccess) async {
        let store = store
        for await current in Observations({ store.subscriptionAccess }) where current == access {
            return
        }
    }
}
