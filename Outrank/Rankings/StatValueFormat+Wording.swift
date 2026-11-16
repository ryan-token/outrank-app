//
//  StatValueFormat+Wording.swift
//  Outrank
//

import Foundation

extension StatValueFormat {
    /// What to call a stat's values over a column of them. The words are the ones the
    /// stats' descriptions use: "Total number of…", "Average number of…", "Percentage of…".
    var columnTitle: LocalizedStringResource {
        switch self {
        case .count: "Total"
        case .decimal, .minutes: "Average"
        case .percent: "Percent"
        case .rating: "Rating"
        case .unlisted: "Value"
        }
    }
}
