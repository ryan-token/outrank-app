//
//  WidgetRankingRow.swift
//  TopFourWidgetExtension
//
//  Created by Ryan Token on 10/9/21.
//

import SwiftUI
import WidgetKit

struct WidgetRankingRow: View {
    let title: String
    let ranking: Int?

    var body: some View {
        HStack {
            Text(title)
                // Long names, such as "Third Down Conversion Pct Defense", take a second line.
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer()

            Text(Conversions.humanReadableRanking(for: ranking))
                .bold()
                .monospacedDigit()
                // Keeps the rankings standing out when the Home Screen tints the widget.
                .widgetAccentable()
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }
}
