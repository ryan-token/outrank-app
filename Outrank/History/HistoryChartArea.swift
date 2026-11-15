//
//  HistoryChartArea.swift
//  Outrank
//

import SwiftUI

/// The chart's place on the History screen: the chart itself, or what stands in for it
/// while a season loads, when it couldn't be loaded, or when it has nothing to plot.
struct HistoryChartArea: View {
    @Environment(HistoryModel.self) private var model

    /// How tall to draw the chart. See `chartHeight(forScreenHeight:)`.
    let chartHeight: Double

    /// Incremented to retry.
    @Binding var reloadAttempt: Int

    var body: some View {
        Group {
            switch model.phase {
            case .loading:
                // As tall as the chart, so the screen doesn't jump when the season arrives.
                ProgressView()
                    .frame(height: chartHeight)
            case .failed:
                ContentUnavailableView {
                    // Not a Wi-Fi symbol or a word about the connection: the model doesn't
                    // know why the load failed.
                    Label("Couldn't Load History", systemImage: "exclamationmark.triangle")
                } description: {
                    Text("Please try again.")
                } actions: {
                    Button("Try Again", action: retry)
                        .buttonStyle(.bordered)
                }
            case .loaded:
                if model.series.latest == nil {
                    ContentUnavailableView {
                        Label("No Rankings", systemImage: "chart.line.flattrend.xyaxis")
                    } description: {
                        Text("\(model.team) has no \(model.series.title) ranking for this season.")
                    }
                } else {
                    HistoryChart()
                        .frame(height: chartHeight)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// The chart's height for a History screen of a given height: enough of the screen
    /// that the chart is the main thing on it, while the stat and season stay in reach
    /// beneath it. The limits keep it readable on iPhone Duo's outer display in landscape
    /// at one end, and from sprawling in a tall iPad window at the other. Whole points,
    /// so a window being dragged resizes the chart a point at a time and not on every
    /// fraction of one.
    ///
    /// Nonisolated because the geometry observer that calls it isn't confined to the main actor.
    nonisolated static func chartHeight(forScreenHeight screenHeight: Double) -> Double {
        min(max((screenHeight * 0.3).rounded(), 160), 380)
    }

    private func retry() {
        reloadAttempt += 1
    }
}
