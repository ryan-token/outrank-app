//
//  SubscriptionStatusKey.swift
//  Outrank
//

import Foundation

/// What the Subscriptions screen works out the user's current subscription from: the
/// subscriptions they hold, and the products to match one against. Either can arrive
/// first, and there is nothing to show until both have.
struct SubscriptionStatusKey: Hashable {
    let activeSubscriptionIDs: Set<String>
    let hasLoadedProducts: Bool
}
