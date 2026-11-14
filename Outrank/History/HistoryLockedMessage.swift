//
//  HistoryLockedMessage.swift
//  Outrank
//

import SwiftUI

/// Says what History is and that a subscription includes it, with the button that opens
/// the subscription options.
struct HistoryLockedMessage: View {
    @Binding var isShowingPaywall: Bool

    var body: some View {
        ContentUnavailableView {
            Label("Follow a Team's Season", systemImage: "chart.line.uptrend.xyaxis")
        } description: {
            Text("""
                History charts any team's ranking in any stat, day by day, for this season and \
                past ones. It's included with every Outrank subscription.
                """)
        } actions: {
            Button("See Subscription Options", action: showPaywall)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
    }

    private func showPaywall() {
        isShowingPaywall = true
    }
}
