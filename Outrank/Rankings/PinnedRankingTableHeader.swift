//
//  PinnedRankingTableHeader.swift
//  Outrank
//

import SwiftUI

/// A copy of the headings over a stat's table of rankings that floats at the top of the
/// screen, on glass, once the table's own have scrolled under the navigation bar, so a
/// row's numbers can still be told apart far down the table.
///
/// An inset grouped list doesn't pin its section headers, so this goes over the list
/// instead. It is always laid out, and only shown while `isPinned`: where it sits is what
/// decides when the table's own headings have scrolled past it.
struct PinnedRankingTableHeader: View {
    let valueColumn: RankingValueColumn?

    /// Where the table's own headings start and how wide they are, in the global
    /// coordinate space, which keeps the copy's columns over the table's.
    let headingsMinX: CGFloat
    let headingsWidth: CGFloat

    let isPinned: Bool

    /// The top of the copy's headings in the global coordinate space: the line the table's
    /// own cross as they scroll under it.
    @Binding var headingsMinY: CGFloat

    /// Where the space the pill floats in starts, to place the headings in it.
    @State private var minX: CGFloat = 0

    /// The room above and below the headings in the pill.
    @ScaledMetric private var verticalPadding = 12.0

    var body: some View {
        RankingTableHeader(valueColumn: valueColumn)
            .frame(width: headingsWidth)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.frame(in: .global).minY
            } action: { minY in
                headingsMinY = minY
            }
            // As far past the headings as a row's background is past its text, so the pill
            // is as wide as the table under it.
            .padding(.horizontal, pillInset)
            .padding(.vertical, verticalPadding)
            .glassEffect(isPinned ? .regular : .identity, in: .capsule)
            .opacity(isPinned ? 1 : 0)
            .animation(.default, value: isPinned)
            .padding(.leading, max(headingsMinX - pillInset - minX, 0))
            .frame(maxWidth: .infinity, alignment: .leading)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.frame(in: .global).minX
            } action: { minX in
                self.minX = minX
            }
            .accessibilityHidden(!isPinned)
            .allowsHitTesting(false)
    }

    /// A list row's text is inset from its background by the list's margin, which is also
    /// how far the background is from the edge of the list.
    private var pillInset: CGFloat {
        max((headingsMinX - minX) / 2, 0)
    }
}
