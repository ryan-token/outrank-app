//
//  StatValueFormat.swift
//  Outrank
//

import Foundation

/// How the number behind a ranking is written out. The backend sends every stat's value as
/// a plain number, so what kind of number it is lives here.
nonisolated enum StatValueFormat: Equatable, Sendable {
    /// Something counted, such as fumbles recovered: "13".
    case count

    /// An average or a rating, to as many decimal places as ncaa.com prints it with:
    /// "534.7" yards a game, "46.95" net yards a punt.
    case decimal(places: Int)

    /// A share of attempts, which arrives as a fraction: 0.589 is "58.9%".
    case percent

    /// Minutes of possession a game: "36.7 min". Not minutes and seconds, because ncaa.com
    /// publishes whole minutes and a tenth of one is as fine as they divide.
    case minutes

    /// A stat this version of the app doesn't list, shown with whatever decimals it has.
    case unlisted

    /// A team's value, such as "534.7", with the same number of decimal places for every
    /// team so a list of them lines up.
    func string(for value: Double) -> String {
        // An unlisted stat's own number of places isn't known, so none are padded on.
        let leastFractionLength = self == .unlisted ? 0 : fractionLength
        return string(for: value, precision: .fractionLength(leastFractionLength...fractionLength))
    }

    /// A value on a chart's scale, where a round number drops its decimals: "500", not "500.0".
    func axisLabel(for value: Double) -> String {
        string(for: value, precision: .fractionLength(0...fractionLength))
    }

    /// The smallest difference between two values that their text can show: 0.1 for a
    /// stat written to one decimal place, and 0.001 for a percentage, which is a fraction
    /// written as "58.9%".
    var smallestStep: Double {
        pow(10, -Double(self == .percent ? fractionLength + 2 : fractionLength))
    }

    private var fractionLength: Int {
        switch self {
        case .count: 0
        case .decimal(let places): places
        case .percent, .minutes: 1
        case .unlisted: 2
        }
    }

    private func string(for value: Double, precision: NumberFormatStyleConfiguration.Precision) -> String {
        switch self {
        case .count, .decimal, .unlisted:
            value.formatted(.number.precision(precision))
        case .percent:
            value.formatted(.percent.precision(precision))
        case .minutes:
            Measurement(value: value, unit: UnitDuration.minutes).formatted(
                .measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(precision))
            )
        }
    }
}
