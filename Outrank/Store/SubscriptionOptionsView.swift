//
//  SubscriptionOptionsView.swift
//  Outrank
//

import StoreKit
import SwiftUI

/// The subscription options under a header of the caller's choosing. The History paywall
/// and the Subscriptions screen in Settings both show this, so the options look and
/// behave the same wherever they are offered.
///
/// StoreKit's own view lists each option with its price and renewal terms, marks the one
/// the user holds, runs the purchase, reports a failed one, and offers the restore button
/// and policy links. A purchase or a restore made here arrives at `Store` through its
/// listeners.
struct SubscriptionOptionsView<Header: View>: View {
    @ViewBuilder let header: Header

    var body: some View {
        SubscriptionStoreView(productIDs: SubscriptionTier.productIDs) {
            header
        }
        .storeButton(.visible, for: .restorePurchases, .policies)
        .subscriptionStorePolicyDestination(url: AppLinks.termsOfUse, for: .termsOfService)
        .subscriptionStorePolicyDestination(url: AppLinks.privacyPolicy, for: .privacyPolicy)
    }
}
