//
//  StatValueBadgeRenderer.swift
//  Outrank
//

import SwiftUI

/// Draws the gray capsule of a `StatValueBadge` behind a value written in the middle of a
/// sentence, where a view can't go: text wraps, and the value has to wrap with it. The
/// capsule is the one the view draws, the same distance past the value on every side.
///
/// `StatValueBadge.inline(_:)` makes the text this looks for.
struct StatValueBadgeRenderer: TextRenderer {
    /// Marks the part of a text that is a stat value.
    struct Attribute: TextAttribute {}

    /// How far the capsule extends past the value: `StatValueBadge.padding`, scaled to
    /// the text size as the view scales its own.
    let padding: CGSize

    /// The capsule reaches a little above and below the line its value is on.
    var displayPadding: EdgeInsets {
        EdgeInsets(top: padding.height, leading: 0, bottom: padding.height, trailing: 0)
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        for line in layout {
            // A value can be laid out as several runs, so the capsule goes around all of
            // them on the line rather than each one.
            let badge = line
                .filter { $0[Attribute.self] != nil }
                .map(\.typographicBounds.rect)
                .reduce(CGRect.null) { $0.union($1) }

            if !badge.isNull {
                let capsule = badge.insetBy(dx: -padding.width, dy: -padding.height)
                context.fill(Capsule().path(in: capsule), with: .color(StatValueBadge.background))
            }
            context.draw(line)
        }
    }
}
