//
//  HistoryPaywallView.swift
//  Outrank
//

import StoreKit
import SwiftUI

/// The subscription options, presented from the locked History tab. A purchase made here
/// unlocks History through `Store`; `HistoryView` then closes this sheet.
struct HistoryPaywallView: View {
    var body: some View {
        SubscriptionOptionsView {
            HistoryPaywallHeader()
        }
        .storeButton(.visible, for: .cancellation)
    }
}

#Preview {
    HistoryPaywallView()
}
