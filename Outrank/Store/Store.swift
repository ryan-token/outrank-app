//
//  Store.swift
//  Outrank
//
//  Created by Ryan Token on 10/17/21.
//

import Foundation
import OSLog
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo

@Observable
final class Store {
    private(set) var tips: [Product] = []
    private(set) var subscriptions: [Product] = []

    /// The subscriptions the user holds right now.
    private(set) var activeSubscriptionIDs: Set<String> = []

    /// Whether the user holds any subscription, which unlocks History.
    private(set) var subscriptionAccess = SubscriptionAccess.unknown

    @ObservationIgnored private var transactionListener: Task<Void, Never>?
    @ObservationIgnored private var statusListener: Task<Void, Never>?

    /// Entitlement checks can overlap, and one that started later can finish first. These
    /// number each check and remember the newest one applied, so a check that finishes
    /// late can't replace a newer one's answer.
    @ObservationIgnored private var entitlementChecksStarted = 0
    @ObservationIgnored private var newestEntitlementCheckApplied = 0

    private let productIdToEmoji: [String: String]
    private let logger = Logger(category: "Store")

    init() {
        if let url = Bundle.main.url(forResource: "Products", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] {
            productIdToEmoji = plist
        } else {
            productIdToEmoji = [:]
        }

        // Start listening as close to app launch as possible so we don't miss any transactions.
        transactionListener = listenForTransactions()
        statusListener = listenForStatusChanges()

        Task {
            // Entitlements come first: they are kept on the device, so what the user has
            // unlocked is known without waiting on a product request to the App Store.
            await refreshEntitlements()
            await requestProducts()
        }
    }

    isolated deinit {
        transactionListener?.cancel()
        statusListener?.cancel()
    }

    /// Purchases made outside the app, renewals, refunds, and purchases made in one of
    /// StoreKit's own views, such as the History paywall, all arrive here.
    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handle(result)
            }
        }
    }

    /// A subscription that lapses sends no transaction, only a change of status, so this
    /// is what locks History again in an app that was left running.
    private func listenForStatusChanges() -> Task<Void, Never> {
        Task { [weak self] in
            for await _ in Product.SubscriptionInfo.Status.updates {
                await self?.refreshEntitlements()
            }
        }
    }

    private func handle(_ update: VerificationResult<Transaction>) async {
        do {
            let transaction = try update.payloadValue
            await refreshEntitlements()
            await transaction.finish()
        } catch {
            logger.error("Transaction failed verification: \(String(describing: error))")
        }
    }

    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIdToEmoji.keys)

            var newTips: [Product] = []
            var newSubscriptions: [Product] = []

            for product in storeProducts {
                switch product.type {
                case .consumable:
                    newTips.append(product)
                case .autoRenewable:
                    newSubscriptions.append(product)
                default:
                    let type = String(describing: product.type)
                    logger.notice("Ignoring product \(product.id, privacy: .public) of type \(type, privacy: .public)")
                }
            }

            tips = sortByPrice(newTips)
            subscriptions = sortByPrice(newSubscriptions)
        } catch {
            logger.error("Failed product request: \(String(describing: error))")
        }
    }

    /// Works out what the user has unlocked from `Transaction.currentEntitlements`, which
    /// holds every subscription that is active or in its billing grace period, and leaves
    /// out ones that have expired or been refunded.
    ///
    /// Runs at launch, whenever a transaction or a change of subscription status arrives,
    /// after a purchase, and when the app returns to the foreground.
    func refreshEntitlements() async {
        #if DEBUG
        // Screenshots show the app as a subscriber sees it, whatever the simulator holds.
        if ScreenshotMode.isEnabled {
            subscriptionAccess = .subscribed
            return
        }
        #endif

        entitlementChecksStarted += 1
        let check = entitlementChecksStarted

        var subscriptionIDs: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  transaction.productType == .autoRenewable,
                  transaction.revocationDate == nil,
                  !transaction.isUpgraded
            else { continue }
            subscriptionIDs.insert(transaction.productID)
        }

        // A check that started after this one read entitlements at least as new.
        guard check > newestEntitlementCheckApplied else { return }
        newestEntitlementCheckApplied = check
        activeSubscriptionIDs = subscriptionIDs
        subscriptionAccess = subscriptionIDs.isEmpty ? .notSubscribed : .subscribed
    }

    /// - Returns: The transaction, or `nil` when the user cancelled or the purchase is
    ///   waiting on approval.
    func purchase(_ product: Product) async throws -> Transaction? {
        switch try await product.purchase() {
        case .success(let verification):
            let transaction = try verification.payloadValue
            await refreshEntitlements()
            await transaction.finish()
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    func emoji(for productId: String) -> String {
        productIdToEmoji[productId] ?? ""
    }

    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted { $0.price < $1.price }
    }
}
