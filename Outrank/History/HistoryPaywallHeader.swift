//
//  HistoryPaywallHeader.swift
//  Outrank
//

import SwiftUI

/// What sits above the subscription options: what a subscription unlocks, and that the
/// options differ only in price.
struct HistoryPaywallHeader: View {
    var body: some View {
        VStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.largeTitle)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Unlock History")
                .font(.title)
                .bold()

            Text("Chart any team's ranking in any stat, day by day, for this season and past ones.")

            Text("Every option unlocks History and supports Outrank's development. Choose whichever suits you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}
