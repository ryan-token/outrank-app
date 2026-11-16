//
//  SettingsLabel.swift
//  Outrank
//
//  Created by Ryan Token on 10/5/21.
//

import SwiftUI

/// A Settings title with its icon, drawn the way the Settings app draws its own: a white
/// symbol on a small rounded square of color, beside a title in the body font. Every row
/// uses it, so the icons share one size and the separators line up.
struct SettingsLabel: View {
    let title: LocalizedStringResource

    /// The symbol's plain name, such as "star". It is drawn filled.
    let icon: String
    let iconColor: Color

    /// The side of the icon's square: 29 points in the Settings app, at the default text
    /// size.
    @ScaledMetric(relativeTo: .body) private var iconSize = 29.0

    /// The share of the square's side that its corners are rounded by.
    private static let cornerRadiusRatio = 0.24

    var body: some View {
        Label {
            Text(title)
                .foregroundStyle(.primary)
        } icon: {
            Image(systemName: icon)
                .symbolVariant(.fill)
                .font(.callout)
                .foregroundStyle(.white)
                .frame(width: iconSize, height: iconSize)
                .background(iconColor, in: .rect(cornerRadius: iconSize * Self.cornerRadiusRatio))
        }
    }
}

#Preview {
    List {
        SettingsLabel(title: "Favorites", icon: "star", iconColor: .yellow)
        SettingsLabel(title: "Leave a Tip", icon: "centsign", iconColor: .orange)
        SettingsLabel(title: "Terms & Privacy Policy", icon: "lock", iconColor: .gray)
    }
}
