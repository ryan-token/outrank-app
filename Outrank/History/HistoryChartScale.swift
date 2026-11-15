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
        let metric = model.plottedMetric

        content
            .chartYScale(domain: yDomain(for: metric, series: series))
            .chartXScale(range: .plotDimension(padding: Self.horizontalPadding))
            .chartPlotStyle { plotArea in
                plotArea.background(
                    plotBackground(for: metric, topHalfFraction: series.topHalfFraction).opacity(0.08),
                    in: .rect(cornerRadius: 8)
                )
            }
    }

    private func yDomain(for metric: HistoryMetric, series: HistorySeries) -> AutomaticScaleDomain {
        switch metric {
        case .ranking:
            // The same scale for every team and stat, upside down so better is higher.
            let rankings = series.scaleDomain
            return .automatic(includesZero: false, reversed: true, dataType: Double.self) { domain in
                domain = [rankings.lowerBound, rankings.upperBound]
            }
        case .value:
            // Values have no field to span, and a stat's range moves through a season, so
            // the scale follows the season's own values. Not from zero: a season of
            // completion percentages would be a flat line near the top. With no values
            // there is nothing plotted, and so nothing for a scale to fit.
            guard let values = series.valueScale?.domain else { return .automatic(includesZero: false) }
            return .automatic(includesZero: false, dataType: Double.self) { domain in
                domain = [values.lowerBound, values.upperBound]
            }
        }
    }

    /// Tinted by half of the field for rankings, and plainly for values, which have no halves.
    private func plotBackground(for metric: HistoryMetric, topHalfFraction: Double) -> AnyShapeStyle {
        switch metric {
        case .ranking: AnyShapeStyle(RankingStyle.scaleGradient(topHalfFraction: topHalfFraction))
        case .value: AnyShapeStyle(Color.secondary)
        }
    }
}

extension View {
    /// Gives the History chart its scales and tints its plot area.
    func historyChartScale() -> some View {
        modifier(HistoryChartScale())
    }
}
