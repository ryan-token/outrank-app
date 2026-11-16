//
//  RankingTableHeaderPin.swift
//  Outrank
//

import Foundation

/// Decides when the headings over a stat's table of rankings have scrolled up past the
/// place their pinned copy floats, and the copy should show.
///
/// While the headings' row is on screen it says where it is, and that settles it. A list
/// drops rows that are off screen, though, and a row dragged past in one jump, by the
/// scroll indicator say, is gone before it can say it crossed. So the place of the
/// headings in the list's content is remembered, and how far the list has scrolled
/// answers for them while they are away.
@Observable
final class RankingTableHeaderPin {
    private(set) var isPinned = false

    /// The top of the pinned copy of the headings, in the global coordinate space: the
    /// line the table's own cross as they scroll under it.
    @ObservationIgnored var pinLine: CGFloat = 0 {
        didSet { update() }
    }

    @ObservationIgnored private var contentOffset: CGFloat = 0

    /// The top of the headings in the global coordinate space, when the row last said.
    @ObservationIgnored private var headingsMinY: CGFloat?

    /// Where the headings would be with the list scrolled to its start: a place that
    /// scrolling doesn't change. `nil` until their row has been on screen.
    @ObservationIgnored private var headingsRestingMinY: CGFloat?

    @ObservationIgnored private var headingsAreOnScreen = false

    func listScrolled(to contentOffset: CGFloat) {
        self.contentOffset = contentOffset
        update()
    }

    /// The headings' row is on screen, with its top at `minY` in the global coordinate space.
    func headingsMoved(to minY: CGFloat) {
        headingsAreOnScreen = true
        headingsMinY = minY
        headingsRestingMinY = minY + contentOffset
        update()
    }

    /// The list dropped the headings' row, which is off screen.
    func headingsLeftScreen() {
        headingsAreOnScreen = false
        update()
    }

    private func update() {
        let minY = headingsAreOnScreen ? headingsMinY : headingsRestingMinY.map { $0 - contentOffset }
        let isPinned = minY.map { $0 < pinLine } ?? false
        // Only a change is worth redrawing for: this runs for every point scrolled.
        if isPinned != self.isPinned {
            self.isPinned = isPinned
        }
    }
}
