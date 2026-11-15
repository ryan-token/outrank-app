//
//  HistoryChartAxes.swift
//  Outrank
//

import Charts
import SwiftUI

/// The History chart's axes, and the crosshair that marks the selected day.
///
/// The crosshair is drawn with axis grid lines rather than marks, and the selection is
/// read here rather than by the chart, so following a touch updates the axes alone and
/// leaves the plotted line as it is.
private struct HistoryChartAxes: ViewModifier {
    @Environment(HistoryModel.self) private var model

    /// Solid and in the label color, so the crosshair stands apart from the dashed and
    /// tinted grid lines around it.
    private static let crosshairStroke = StrokeStyle(lineWidth: 1)

    func body(content: Content) -> some View {
        let selectedPoint = model.selectedPoint

        content
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4))

                if let selectedPoint {
                    AxisMarks(values: [selectedPoint.date]) {
                        AxisGridLine(stroke: Self.crosshairStroke)
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: model.series.axisRankings) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let ranking = value.as(Double.self) {
                            Text(Conversions.humanReadableRanking(for: Int(ranking)))
                        }
                    }
                }

                // A day without a ranking has nowhere on this axis to mark.
                if let ranking = selectedPoint?.ranking {
                    AxisMarks(values: [Double(ranking)]) {
                        AxisGridLine(stroke: Self.crosshairStroke)
                            .foregroundStyle(Color.primary)
                    }
                }
            }
    }
}

extension View {
    /// Draws the History chart's axes, with a crosshair on the selected day.
    func historyChartAxes() -> some View {
        modifier(HistoryChartAxes())
    }
}
