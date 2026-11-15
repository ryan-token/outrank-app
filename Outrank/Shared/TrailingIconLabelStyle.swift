//
//  TrailingIconLabelStyle.swift
//  Outrank
//

import SwiftUI

/// A label with its icon after its title, as with the chevron that follows a menu's value.
struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}
