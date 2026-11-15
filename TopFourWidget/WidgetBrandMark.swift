//
//  WidgetBrandMark.swift
//  TopFourWidgetExtension
//

import SwiftUI
import WidgetKit

/// The app icon's U and football, without the icon's green tile, so it sits on either
/// widget background.
struct WidgetBrandMark: View {
    @ScaledMetric(relativeTo: .title2) private var size = 30

    var body: some View {
        Image(.outrankMark)
            .resizable()
            // Keeps the artwork's light and dark areas when the Home Screen tints the
            // widget. As a plain template it would fill in to a solid silhouette.
            .widgetAccentedRenderingMode(.desaturated)
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}
