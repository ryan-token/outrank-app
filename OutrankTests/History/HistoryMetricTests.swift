//
//  HistoryMetricTests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct HistoryMetricTests {
    private static let timeZone = TimeZone(identifier: "America/Chicago") ?? .gmt

    /// 2026 has values from its second day on; 2025 is from before they were recorded.
    private static func history(season: String?) -> TeamHistory {
        TeamHistory(
            season: season ?? "2026",
            dates: ["2026-09-08", "2026-09-09", "2026-09-10"],
            ranks: ["ScoringOffense": [80, 70, nil]],
            values: season == nil ? ["ScoringOffense": [nil, 31.5, nil]] : [:]
        )
    }

    private func makeModel(defaults: UserDefaults) -> HistoryModel {
        HistoryModel(
            defaults: defaults,
            timeZone: Self.timeZone,
            fetchHistory: { _, season in Self.history(season: season) },
            fetchMetadata: { RankingsMetadata(seasons: ["2025", "2026"], scrapedAt: nil) },
            now: Date.init
        )
    }

    @Test func chartPlotsValuesOnlyForASeasonThatHasThem() async {
        let defaults = makeIsolatedDefaults()
        defaults.set("Tulsa", forKey: HistoryModel.teamKey)
        let model = makeModel(defaults: defaults)
        model.metric = .value
        await model.load()

        #expect(model.plottedMetric == .value)
        // The readout follows the value line, which ends on the last day with a value.
        #expect(model.focusedPoint == model.series.points[1])

        model.selectedSeason = "2025"
        // While the next season loads, the choice stays as the last one left it.
        #expect(model.offersValues)
        await model.load()

        #expect(model.offersValues == false)
        #expect(model.plottedMetric == .ranking)
        #expect(model.focusedPoint == model.series.latest)
        // The choice is kept for the seasons that can show it, and for the next launch.
        #expect(model.metric == .value)
        #expect(makeModel(defaults: defaults).metric == .value)
    }
}
