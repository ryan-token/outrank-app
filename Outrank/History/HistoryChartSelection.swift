//
//  HistoryChartSelection.swift
//  Outrank
//

import Charts
import SwiftUI

/// Lets a touch be dragged across the History chart to pick a day.
///
/// The binding is made here, so the chart itself never reads the position as it changes.
private struct HistoryChartSelection: ViewModifier {
    @Environment(HistoryModel.self) private var model

    func body(content: Content) -> some View {
        @Bindable var model = model

        content
            .chartXSelection(value: $model.rawSelectedDate)
            // A tick for each new day reached, and none for letting go.
            .sensoryFeedback(trigger: model.selectedPoint) { _, selectedPoint in
                selectedPoint == nil ? nil : .selection
            }
    }
}

extension View {
    /// Lets a day be picked by dragging across the History chart.
    func historyChartSelection() -> some View {
        modifier(HistoryChartSelection())
    }
}
