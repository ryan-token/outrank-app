//
//  HistoryChartScale.swift
//  Outrank
//

import Charts
import SwiftUI

/// The History chart's scales, and the plot area they lay the season out in.
private struct HistoryChartScale: ViewModifier {
    @Environment(HistoryModel.self) private var model

    /// Room beside the first and last days, so the dots there aren't drawn over the edge.
    private static let horizontalPadding: Double = 6

    func body(content: Content) -> some View {
        let series = model.series
        let scaleDomain = series.scaleDomain

        content
            // The same scale for every team and stat, upside down so better is higher.
            .chartYScale(domain: .automatic(includesZero: false, reversed: true, dataType: Double.self) { domain in
                domain = [scaleDomain.lowerBound, scaleDomain.upperBound]
            })
            .chartXScale(range: .plotDimension(padding: Self.horizontalPadding))
            .chartPlotStyle { plotArea in
                plotArea.background(
                    RankingStyle.scaleGradient(topHalfFraction: series.topHalfFraction).opacity(0.08),
                    in: .rect(cornerRadius: 8)
                )
            }
    }
}

extension View {
    /// Gives the History chart its scales and tints its plot area by half of the field.
    func historyChartScale() -> some View {
        modifier(HistoryChartScale())
    }
}
