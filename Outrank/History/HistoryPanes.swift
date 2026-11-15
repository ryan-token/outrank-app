//
//  HistoryPanes.swift
//  Outrank
//

import SwiftUI

/// The History screen's content: the chart, then the choices and the summary.
///
/// They are one list, except while iPhone Duo is partly folded. Then the chart takes one
/// side of the fold and the rest the other, so the fold doesn't run through the chart.
struct HistoryPanes: View {
    @Environment(\.isDividedByFold) private var isDividedByFold

    /// How tall to draw the chart in the one list. A pane of its own sizes it for itself.
    let chartHeight: Double

    /// Incremented to retry.
    @Binding var reloadAttempt: Int

    var body: some View {
        if #available(iOS 27.1, *), isDividedByFold {
            ArrangementView {
                HistoryChartPane(reloadAttempt: $reloadAttempt)
                    .foldSidePadding(horizontal: .trailing, vertical: .bottom)
            } secondary: {
                List {
                    HistoryOptionsSection()
                    HistorySummarySection()
                }
                .foldSidePadding(horizontal: .leading, vertical: .top)
            }
            .arrangementViewStyle(.split)
        } else {
            List {
                HistoryChartSection(chartHeight: chartHeight, reloadAttempt: $reloadAttempt)
                HistoryOptionsSection()
                HistorySummarySection()
            }
        }
    }
}

#if DEBUG
#Preview("Rankings", traits: .modifier(HistoryPreviewData())) {
    NavigationStack {
        HistoryPanes(chartHeight: 280, reloadAttempt: .constant(0))
    }
}

#Preview("Values", traits: .modifier(HistoryPreviewData(metric: .value))) {
    NavigationStack {
        HistoryPanes(chartHeight: 280, reloadAttempt: .constant(0))
    }
}
#endif
