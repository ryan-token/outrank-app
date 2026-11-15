//
//  HistoryChart.swift
//  Outrank
//

import Charts
import SwiftUI

/// A team's ranking in one stat on each day of a season, with 1st at the top so the line
/// climbs as the team improves; or, when the model plots values, the stat's value on each
/// of those days.
///
/// The body reads only the prepared series. The scales, the axes, and whatever changes
/// while a selection is followed across the chart are read by the modifiers at the end
/// instead, so the marks aren't rebuilt for them.
struct HistoryChart: View {
    @Environment(HistoryModel.self) private var model

    var body: some View {
        Chart {
            let series = model.series

            switch model.plottedMetric {
            case .ranking:
                HistoryMarks(series: series)
                    // One fill laid over the whole plot area rather than each mark, so a
                    // mark's color says which half of the field it sits in.
                    .foregroundStyle(RankingStyle.scaleGradient(topHalfFraction: series.topHalfFraction))
                    .alignsMarkStylesWithPlotArea()
            case .value:
                // One color that is neither of the ranking colors, and not the app's green
                // tint: a value isn't good or bad without its ranking, and whether higher
                // is better depends on the stat.
                HistoryValueMarks(series: series)
                    .foregroundStyle(.blue)
            }
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

#Preview("Values", traits: .modifier(HistoryPreviewData(metric: .value))) {
    HistoryChart()
        .frame(height: 300)
        .padding()
}

// The first days after the backend starts recording values: a season of rankings, with a
// value on its last two days alone.
#Preview("First Values") {
    @Previewable @State var model = HistoryModel(
        defaults: UserDefaults(suiteName: "HistoryPreview") ?? .standard,
        fetchHistory: { team, season in
            let history = try await ScreenshotFixtures.teamHistory(for: team, season: season)
            let recent = history.dates.count - 2
            return TeamHistory(
                season: history.season,
                dates: history.dates,
                ranks: history.ranks,
                values: history.values.mapValues { values in
                    values.enumerated().map { $0.offset < recent ? nil : $0.element }
                }
            )
        },
        fetchMetadata: ScreenshotFixtures.metadata
    )

    HistoryChart()
        .frame(height: 300)
        .padding()
        .environment(model)
        .task {
            model.metric = .value
            await model.load()
        }
}

#Preview("Selected Value", traits: .modifier(HistoryPreviewData(selectsDay: true, metric: .value))) {
    HistoryChart()
        .frame(height: 300)
        .padding()
}
#endif
