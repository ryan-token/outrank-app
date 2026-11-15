//
//  WidgetBackdrop.swift
//  TopFourWidgetExtension
//

import SwiftUI

/// The widget's background: its color at the leading edge, deepening across the whole
/// width. Both ends are dark enough for white text, in light and dark appearances alike.
struct WidgetBackdrop: View {
    let type: WidgetType

    var body: some View {
        LinearGradient(colors: type.backgroundColors, startPoint: .leading, endPoint: .trailing)
    }
}
