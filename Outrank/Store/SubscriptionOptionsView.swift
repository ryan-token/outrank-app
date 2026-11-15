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
/// the user holds, runs the purchase, reports a failed one, and offers the restore button.
/// A purchase or a restore made here arrives at `Store` through its listeners.
///
/// The policy links are the app's own, under the header where StoreKit puts its policy
/// buttons. See `SubscriptionPolicyLinks` for why.
struct SubscriptionOptionsView<Header: View>: View {
    @ContentBuilder let header: Header

    /// The widest the header gets, close to the width StoreKit gives the options under
    /// it. Without a limit its text runs the full width of a Mac window or a landscape
    /// iPad in long, hard-to-read lines. Scales with the text size, so larger text
    /// keeps a similar number of words on each line.
    @ScaledMetric(relativeTo: .body) private var headerMaxWidth = 380.0

    var body: some View {
        SubscriptionStoreView(productIDs: SubscriptionTier.productIDs) {
            VStack {
                header
                SubscriptionPolicyLinks()
            }
            .frame(maxWidth: headerMaxWidth)
        }
        .storeButton(.visible, for: .restorePurchases)
        .storeButton(.hidden, for: .policies)
    }
}
