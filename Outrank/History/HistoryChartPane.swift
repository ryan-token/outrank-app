//
//  HistoryChartPane.swift
//  Outrank
//

import SwiftUI

/// The chart in a pane of its own, beside or above the rest of the History screen.
///
/// The chart is sized from the pane and not the screen: stacked above the fold, the pane
/// is about half the screen's height, and a chart sized for all of it wouldn't fit.
struct HistoryChartPane: View {
    /// Incremented to retry.
    @Binding var reloadAttempt: Int

    @State private var chartHeight = HistoryChartArea.chartHeight(forScreenHeight: 0)

    var body: some View {
        List {
            HistoryChartSection(chartHeight: chartHeight, reloadAttempt: $reloadAttempt)
        }
        .onGeometryChange(for: Double.self) { geometry in
            HistoryChartArea.chartHeight(forScreenHeight: geometry.size.height)
        } action: { height in
            chartHeight = height
        }
    }
}
