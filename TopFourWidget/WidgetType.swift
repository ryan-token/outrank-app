//
//  WidgetType.swift
//  TopFourWidgetExtension
//
//  Created by Ryan Token on 10/9/21.
//

import SwiftUI

enum WidgetType {
    case topFour
    case bottomFour

    var label: String {
        switch self {
        case .topFour: "Top Four"
        case .bottomFour: "Bottom Four"
        }
    }

    var symbol: String {
        switch self {
        case .topFour: "arrow.up"
        case .bottomFour: "arrow.down"
        }
    }

    var sortMethod: SortMethod {
        switch self {
        case .topFour: .byRankingAscending
        case .bottomFour: .byRankingDescending
        }
    }

    /// Green for a team's best stats and red for its worst, each running from the full
    /// color to a deep shade of it.
    var backgroundColors: [Color] {
        switch self {
        case .topFour:
            [.somewhatLighterDarkGreen, Color(red: 0 / 255, green: 48 / 255, blue: 18 / 255)]
        case .bottomFour:
            [
                Color(red: 196 / 255, green: 30 / 255, blue: 45 / 255),
                Color(red: 66 / 255, green: 8 / 255, blue: 16 / 255)
            ]
        }
    }
}
