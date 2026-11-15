//
//  HistoryPreviewData.swift
//  Outrank
//

#if DEBUG
import SwiftUI

/// Gives a preview a History model that has already loaded the frozen screenshot season,
/// so the chart previews with real rankings and without the network.
struct HistoryPreviewData: PreviewModifier {
    /// Whether to point at a day in the middle of the season, to preview the crosshair.
    var selectsDay = false

    /// What the chart plots.
    var metric = HistoryMetric.ranking

    static func makeSharedContext() async throws -> HistoryModel {
        // A fixed literal, so a failure here is a typo caught the first time a preview runs.
        guard let defaults = UserDefaults(suiteName: "HistoryPreview") else {
            preconditionFailure("Could not create the preview's defaults.")
        }

        let model = HistoryModel(
            defaults: defaults,
            fetchHistory: ScreenshotFixtures.teamHistory(for:season:),
            fetchMetadata: ScreenshotFixtures.metadata
        )
        model.team = "Tulsa"
        model.stat = HistoryModel.defaultStat
        await model.load()
        return model
    }

    func body(content: Content, context: HistoryModel) -> some View {
        content
            .environment(context)
            .onAppear {
                context.metric = metric
                let points = context.series.points
                context.rawSelectedDate = selectsDay ? points[points.count / 2].date : nil
            }
    }
}
#endif
