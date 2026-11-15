//
//  HistorySummarySection.swift
//  Outrank
//

import SwiftUI

/// The best and worst the team ranked in the chosen stat over the season on screen.
struct HistorySummarySection: View {
    @Environment(HistoryModel.self) private var model

    var body: some View {
        let series = model.series

        if let best = series.best, let worst = series.worst {
            Section("Season Summary") {
                HistorySummaryRow(title: "Best", point: best)
                HistorySummaryRow(title: "Worst", point: worst)
            }
        }
    }
}
