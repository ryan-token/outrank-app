//
//  HorizontalSpan.swift
//  Outrank
//

import SwiftUI

/// Where something starts and how wide it is, without where it is vertically: a view that
/// follows another's columns isn't redrawn as that one scrolls.
nonisolated struct HorizontalSpan: Equatable, Sendable {
    var minX: CGFloat = 0
    var width: CGFloat = 0
}

extension View {
    /// Reports where the view starts and how wide it is in the global coordinate space,
    /// whenever either changes.
    func onHorizontalSpanChange(_ action: @escaping (HorizontalSpan) -> Void) -> some View {
        onGeometryChange(for: HorizontalSpan.self) { proxy in
            let frame = proxy.frame(in: .global)
            return HorizontalSpan(minX: frame.minX, width: frame.width)
        } action: { span in
            action(span)
        }
    }
}
