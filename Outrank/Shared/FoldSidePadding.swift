//
//  FoldSidePadding.swift
//  Outrank
//

import SwiftUI

/// Keeps a pane's content off the fold it sits beside. A split arrangement lays its panes
/// out right up to the fold, where a list's rows would otherwise touch it.
@available(iOS 27.1, *)
private struct FoldSidePadding: ViewModifier {
    @Environment(\.splitArrangementAxis) private var splitArrangementAxis

    /// The pane's edge that faces the fold when the panes are side by side.
    let horizontalEdge: Edge.Set

    /// The pane's edge that faces the fold when the panes are stacked.
    let verticalEdge: Edge.Set

    private var edge: Edge.Set {
        switch splitArrangementAxis {
        case .horizontal: horizontalEdge
        case .vertical: verticalEdge
        case nil: []
        }
    }

    func body(content: Content) -> some View {
        // Safe area padding, so the pane's background still reaches the fold.
        content.safeAreaPadding(edge)
    }
}

@available(iOS 27.1, *)
extension View {
    /// Pads the edge of a split arrangement's pane that faces the fold, by the system's
    /// standard amount: one edge when the panes are side by side, another when stacked.
    func foldSidePadding(horizontal: Edge.Set, vertical: Edge.Set) -> some View {
        modifier(FoldSidePadding(horizontalEdge: horizontal, verticalEdge: vertical))
    }
}
