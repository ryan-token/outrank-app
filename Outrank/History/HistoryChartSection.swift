//
//  HistoryChartSection.swift
//  Outrank
//

import SwiftUI

/// The chart with the readout of the day it is pointing at above it.
struct HistoryChartSection: View {
    /// How tall to draw the chart. See `HistoryChartArea.chartHeight(forScreenHeight:)`.
    let chartHeight: Double

    /// Incremented to retry.
    @Binding var reloadAttempt: Int

    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HistoryReadout()
                HistoryChartArea(chartHeight: chartHeight, reloadAttempt: $reloadAttempt)
            }
        }
    }
}
