//
//  FoldDivisionReader.swift
//  Outrank
//

import SwiftUI

/// Tells the views inside whether a fold currently divides them, as iPhone Duo's does
/// while it is partly folded. Flat or closed, and on every other device, nothing does.
private struct FoldDivisionReader: ViewModifier {
    @State private var isDividedByFold = false

    func body(content: Content) -> some View {
        if #available(iOS 27.1, *) {
            content
                .environment(\.isDividedByFold, isDividedByFold)
                .onGeometryChange(for: Bool.self) { geometry in
                    geometry.reservedRegions(kind: .division).contains(where: \.isActive)
                } action: { isDivided in
                    isDividedByFold = isDivided
                }
        } else {
            content
        }
    }
}

extension View {
    /// Sets `isDividedByFold` for the views inside from the space this view fills.
    func readsFoldDivision() -> some View {
        modifier(FoldDivisionReader())
    }
}

extension EnvironmentValues {
    /// Whether a fold currently divides the screen the view is on. See `readsFoldDivision()`.
    @Entry var isDividedByFold = false
}
