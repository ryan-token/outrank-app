//
//  SubscriptionsView.swift
//  Outrank
//
//  Created by Ryan Token on 10/17/21.
//

import OSLog
import StoreKit
import SwiftUI

/// The Subscriptions screen in Settings: the same options the History paywall offers,
/// under where the user's own subscription stands.
struct SubscriptionsView: View {
    @Environment(Store.self) private var store

    @State private var currentSubscription: Product?
    @State private var status: Product.SubscriptionInfo.Status?
    @State private var isShowingManageSubscriptions = false

    private static let logger = Logger(category: "SubscriptionsView")

    var body: some View {
        SubscriptionOptionsView {
            SubscriptionsHeader(currentSubscription: currentSubscription, status: status)
        }
        // The page is left with the back button; a close button beside it would do the same.
        .storeButton(.hidden, for: .cancellation)
        .navigationTitle("Subscriptions")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: SubscriptionStatusKey(
            activeSubscriptionIDs: store.activeSubscriptionIDs,
            hasLoadedProducts: !store.subscriptions.isEmpty
        )) {
            await updateSubscriptionStatus()
        }
        .manageSubscriptionsSheet(isPresented: $isShowingManageSubscriptions)
        .toolbar {
            // Only a subscriber has a subscription to manage.
            if currentSubscription != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button("Manage Subscription", systemImage: "creditcard", action: showManageSubscriptions)
                }
            }
        }
    }

    private func showManageSubscriptions() {
        isShowingManageSubscriptions = true
    }

    private func updateSubscriptionStatus() async {
        do {
            guard let product = store.subscriptions.first,
                  let statuses = try await product.subscription?.status else {
                return
            }

            var highestStatus: Product.SubscriptionInfo.Status?
            var highestProduct: Product?

            for status in statuses {
                switch status.state {
                case .expired, .revoked:
                    continue
                default:
                    let renewalInfo = try status.renewalInfo.payloadValue

                    guard let newSubscription = store.subscriptions.first(where: {
                        $0.id == renewalInfo.currentProductID
                    }) else {
                        continue
                    }

                    guard let currentProduct = highestProduct else {
                        highestStatus = status
                        highestProduct = newSubscription
                        continue
                    }

                    let highestTier = SubscriptionTier(productID: currentProduct.id)
                    let newTier = SubscriptionTier(productID: renewalInfo.currentProductID)

                    if newTier > highestTier {
                        highestStatus = status
                        highestProduct = newSubscription
                    }
                }
            }

            status = highestStatus
            currentSubscription = highestProduct
        } catch {
            Self.logger.error("Could not update subscription status: \(String(describing: error))")
        }
    }
}

#Preview {
    NavigationStack {
        SubscriptionsView()
            .environment(Store())
    }
}
