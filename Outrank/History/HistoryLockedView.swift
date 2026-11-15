//
//  HistoryLockedView.swift
//  Outrank
//

import SwiftUI

/// What the History tab shows without a subscription: what History is, and one button
/// that leads to the subscription options.
struct HistoryLockedView: View {
    @Binding var isShowingPaywall: Bool

    var body: some View {
        // Centered when there is room for it, and scrolling when there isn't, such as on
        // iPhone Duo's outer display in landscape or at the largest text sizes.
        ViewThatFits(in: .vertical) {
            HistoryLockedMessage(isShowingPaywall: $isShowingPaywall)

            ScrollView {
                HistoryLockedMessage(isShowingPaywall: $isShowingPaywall)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HistoryLockedView(isShowingPaywall: .constant(false))
    }
}
