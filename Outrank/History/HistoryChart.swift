//
//  HistoryChart.swift
//  Outrank
//

import Charts
import SwiftUI

/// A team's ranking in one stat on each day of a season, with 1st at the top so the line
/// climbs as the team improves.
///
/// The body reads only the prepared series. The scales, the axes, and whatever changes
/// while a selection is followed across the chart are read by the modifiers at the end
/// instead, so the marks aren't rebuilt for them.
struct HistoryChart: View {
    @Environment(HistoryModel.self) private var model

    var body: some View {
        Chart {
            let series = model.series

            HistoryMarks(series: series)
                // One fill laid over the whole plot area rather than each mark, so a
                // mark's color says which half of the field it sits in.
                .foregroundStyle(RankingStyle.scaleGradient(topHalfFraction: series.topHalfFraction))
                .alignsMarkStylesWithPlotArea()
        }
        .historyChartScale()
        .historyChartAxes()
        .historyChartSelection()
    }
}

#if DEBUG
#Preview("Season", traits: .modifier(HistoryPreviewData())) {
    HistoryChart()
        .frame(height: 300)
        .padding()
}

#Preview("Selected Day", traits: .modifier(HistoryPreviewData(selectsDay: true))) {
    HistoryChart()
        .frame(height: 300)
        .padding()
}
#endif
