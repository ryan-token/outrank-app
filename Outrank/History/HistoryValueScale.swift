//
//  HistoryValueScale.swift
//  Outrank
//

import Foundation

/// The History chart's scale for one stat's values across a season: the values it labels,
/// and how far it extends.
///
/// Worked out from the season's own values rather than left to the chart, because a value
/// only moves when a team plays. A season's first weeks hold one value, or a few that
/// barely differ, and a scale fitted to those would label every line with the same text.
nonisolated struct HistoryValueScale: Equatable, Sendable {
    /// The values to label, evenly spaced and in ascending order. Never fewer than three.
    let ticks: [Double]

    /// From a little below the first tick to a little above the last, so a line running
    /// along either one isn't drawn on the edge of the chart.
    let domain: ClosedRange<Double>

    /// How many steps the season's values should span, more or less.
    private static let desiredSteps = 4.0

    /// How far the scale extends past its first and last ticks, as a share of a step.
    private static let edgePadding = 0.25

    /// Forgives the rounding error in dividing by a step such as 0.1, which would
    /// otherwise put a value that sits exactly on a tick just past it.
    private static let tolerance = 1e-9

    /// - Parameters:
    ///   - values: The season's values, in any order. `nil` is returned when there are none.
    ///   - smallestStep: The smallest difference the values' text can show. Ticks are never
    ///     closer together than this, so no two of them read the same.
    init?(values: [Double], smallestStep: Double) {
        guard let low = values.min(), let high = values.max(), smallestStep > 0 else { return nil }

        let step = Self.roundStep(atLeast: max((high - low) / Self.desiredSteps, smallestStep))
        var first = Int((low / step + Self.tolerance).rounded(.down))
        var last = Int((high / step - Self.tolerance).rounded(.up))
        // A season whose values are all the same, or nearly, still gets a scale around them.
        if last - first < 2 {
            first -= 1
            last += 1
        }

        // Multiplied out from whole numbers, rather than added up step by step, so the
        // last tick is as exact as the first.
        ticks = (first...last).map { Double($0) * step }
        domain = ((Double(first) - Self.edgePadding) * step)...((Double(last) + Self.edgePadding) * step)
    }

    /// The smallest of 1, 2 or 5 times a power of ten that is at least `minimum`: the steps
    /// a scale can count in and still read as round numbers.
    private static func roundStep(atLeast minimum: Double) -> Double {
        let magnitude = pow(10, log10(minimum).rounded(.down))
        let multiple = [1.0, 2, 5].first { minimum / magnitude <= $0 + tolerance } ?? 10
        return multiple * magnitude
    }
}
