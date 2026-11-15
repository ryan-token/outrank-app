//
//  WidgetTeamPanel.swift
//  TopFourWidgetExtension
//

import SwiftUI

/// The leading side of the widget: which team, and whether these are its best or worst stats.
struct WidgetTeamPanel: View {
    let type: WidgetType
    let team: String

    var body: some View {
        VStack(alignment: .leading) {
            WidgetBrandMark()

            Spacer()

            Label(type.label, systemImage: type.symbol)
                .font(.caption)
                .bold()
                .opacity(0.85)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(team)
                .font(.title2)
                .bold()
                // The lines of a wrapped name sit close, so it reads as one name.
                .lineHeight(.multiple(factor: 0.9))
                .lineLimit(3)
                // Long names, such as "Southern California", shrink before they truncate.
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
