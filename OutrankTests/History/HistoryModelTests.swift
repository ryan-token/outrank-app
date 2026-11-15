//
//  HistoryModelTests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct HistoryModelTests {
    private struct Request: Equatable {
        let team: String
        let season: String?
    }

    private static let timeZone = TimeZone(identifier: "America/Chicago") ?? .gmt

    private static func history(season: String? = nil) -> TeamHistory {
        TeamHistory(
            season: season ?? "2026",
            dates: ["2026-09-08", "2026-09-09", "2026-09-10"],
            ranks: ["ScoringOffense": [80, nil, 60], "TotalDefense": [10, 11, 12]]
        )
    }

    private static let metadata = RankingsMetadata(seasons: ["2025", "2026"], scrapedAt: nil)

    /// Defaults with Tulsa already chosen, as after an earlier visit to History.
    private func makeDefaults() -> UserDefaults {
        let defaults = makeIsolatedDefaults()
        defaults.set("Tulsa", forKey: HistoryModel.teamKey)
        return defaults
    }

    private func makeModel(
        defaults: UserDefaults? = nil,
        fetchHistory: @escaping (String, String?) async throws -> TeamHistory = { _, season in
            history(season: season)
        },
        fetchMetadata: @escaping () async throws -> RankingsMetadata = { metadata },
        now: @escaping () -> Date = Date.init
    ) -> HistoryModel {
        HistoryModel(
            defaults: defaults ?? makeDefaults(),
            timeZone: Self.timeZone,
            fetchHistory: fetchHistory,
            fetchMetadata: fetchMetadata,
            now: now
        )
    }

    @Test func firstVisitStartsOnTheRankingsTabsTeamThenKeepsItsOwn() {
        let defaults = makeIsolatedDefaults()
        defaults.set("SMU", forKey: TeamRankingsModel.teamKey)
        let model = makeModel(defaults: defaults)
        #expect(model.team == "SMU")

        model.team = "Rice"
        defaults.set("Tulsa", forKey: TeamRankingsModel.teamKey)

        #expect(makeModel(defaults: defaults).team == "Rice")
    }

    @Test func chosenStatIsRestoredEvenWhenOnlyTheBackendHasIt() async {
        let defaults = makeDefaults()
        makeModel(defaults: defaults).stat = "TotalDefense"
        #expect(makeModel(defaults: defaults).stat == "TotalDefense")

        // Added by the backend after this version shipped, so the app's catalog lacks it.
        defaults.set("BrandNewStat", forKey: HistoryModel.statKey)
        let model = makeModel(defaults: defaults, fetchHistory: { _, _ in
            TeamHistory(season: "2026", dates: ["2026-09-08"], ranks: ["BrandNewStat": [7]])
        })
        // Listed before anything loads, so the stat picker has its selection to show.
        #expect(model.stats.contains("BrandNewStat"))

        await model.load()

        #expect(model.stat == "BrandNewStat")
        #expect(model.series.points.map(\.ranking) == [7])
    }

    @Test func savedStatThatNoLongerExistsGivesWayToTheDefault() async {
        let defaults = makeDefaults()
        defaults.set("RetiredStat", forKey: HistoryModel.statKey)
        let model = makeModel(defaults: defaults)

        await model.load()

        #expect(model.stat == HistoryModel.defaultStat)
        #expect(model.series.points.map(\.ranking) == [80, nil, 60])
        #expect(model.stats.contains("RetiredStat") == false)
    }

    @Test func loadChartsTheChosenStatAndListsSeasonsNewestFirst() async {
        var requests: [Request] = []
        let model = makeModel(fetchHistory: { team, season in
            requests.append(Request(team: team, season: season))
            return Self.history()
        })
        #expect(model.phase == .loading)

        await model.load()

        #expect(model.phase == .loaded)
        // With no season chosen, the backend picks the team's latest.
        #expect(requests == [Request(team: "Tulsa", season: nil)])
        #expect(model.series.title == "Scoring Offense")
        #expect(model.series.points.map(\.ranking) == [80, nil, 60])
        #expect(model.seasons == ["2026", "2025"])
        #expect(model.selectedSeason == "2026")
    }

    @Test func changingTheStatRechartsWithoutFetchingAgain() async {
        var fetchCount = 0
        let model = makeModel(fetchHistory: { _, _ in
            fetchCount += 1
            return Self.history()
        })
        await model.load()

        model.stat = "TotalDefense"

        #expect(model.series.title == "Total Defense")
        #expect(model.series.points.map(\.ranking) == [10, 11, 12])
        #expect(fetchCount == 1)
    }

    @Test func changingTheTeamDropsTheOldTeamsHistory() async {
        var requests: [Request] = []
        let model = makeModel(fetchHistory: { team, season in
            requests.append(Request(team: team, season: season))
            return Self.history()
        })
        await model.load()

        model.team = "SMU"

        // Nothing of Tulsa's may show under SMU's name while SMU loads.
        #expect(model.phase == .loading)
        #expect(model.series == .empty)

        await model.loadIfStale()
        #expect(requests.last == Request(team: "SMU", season: nil))
        #expect(model.phase == .loaded)
    }

    @Test func choosingAnOlderSeasonRequestsItAndTheNewestFollowsTheLatestAgain() async {
        var requests: [Request] = []
        let model = makeModel(fetchHistory: { team, season in
            requests.append(Request(team: team, season: season))
            return Self.history(season: season)
        })
        await model.load()

        model.selectedSeason = "2025"
        #expect(model.phase == .loading)
        await model.loadIfStale()
        #expect(requests.last == Request(team: "Tulsa", season: "2025"))
        #expect(model.selectedSeason == "2025")

        // Not pinned to 2026, so the screen moves on by itself when a new season starts.
        model.selectedSeason = "2026"
        await model.loadIfStale()
        #expect(requests.last == Request(team: "Tulsa", season: nil))
    }

    @Test func responseForAPreviousTeamIsIgnored() async {
        let reference = ModelReference<HistoryModel>()
        let model = makeModel(fetchHistory: { _, _ in
            // The user picks another team while this request is in flight.
            reference.model?.team = "SMU"
            return Self.history()
        })
        reference.model = model

        await model.load()

        #expect(model.phase == .loading)
        #expect(model.series == .empty)
    }

    @Test func retryAfterAFailedLoadShowsItIsLoadingAgain() async {
        let reference = ModelReference<HistoryModel>()
        var phasesWhileFetching: [HistoryPhase] = []
        let model = makeModel(fetchHistory: { _, _ in
            if let phase = reference.model?.phase {
                phasesWhileFetching.append(phase)
            }
            throw StubError()
        })
        reference.model = model
        await model.load()
        #expect(model.phase == .failed)

        await model.load()

        // The second fetch ran with progress on screen, not the first one's failure.
        #expect(phasesWhileFetching == [.loading, .loading])
        #expect(model.phase == .failed)
    }

    @Test func failedRefreshKeepsTheSeasonOnScreen() async {
        var shouldFail = false
        let model = makeModel(fetchHistory: { _, _ in
            if shouldFail { throw StubError() }
            return Self.history()
        })
        await model.load()

        shouldFail = true
        await model.load()

        #expect(model.phase == .loaded)
        #expect(model.series.points.count == 3)
    }

    @Test func cancelledLoadIsNotReportedAsAFailure() async {
        let model = makeModel(fetchHistory: { _, _ in
            // SwiftUI cancels the task when the view disappears or the team changes.
            withUnsafeCurrentTask { $0?.cancel() }
            throw CancellationError()
        })

        await Task { await model.load() }.value

        #expect(model.phase == .loading)
    }

    @Test func seasonsFallBackToTheLoadedOneUntilTheBackendListsThem() async {
        var metadataRequests = 0
        let model = makeModel(fetchMetadata: {
            metadataRequests += 1
            if metadataRequests == 1 { throw StubError() }
            return Self.metadata
        })

        await model.load()
        #expect(model.phase == .loaded)
        #expect(model.seasons == ["2026"])

        await model.load()
        #expect(model.seasons == ["2026", "2025"])

        // Once listed, the seasons aren't asked for again.
        await model.load()
        #expect(metadataRequests == 2)
    }

    @Test func seasonThatStartsAfterTheSeasonsWereListedJoinsThem() async {
        var latestSeason = "2026"
        var requests: [Request] = []
        let model = makeModel(fetchHistory: { team, season in
            requests.append(Request(team: team, season: season))
            return Self.history(season: season ?? latestSeason)
        })
        await model.load()
        #expect(model.seasons == ["2026", "2025"])

        // The app is still running when the next season's rankings start.
        latestSeason = "2027"
        await model.load()

        #expect(model.seasons == ["2027", "2026", "2025"])
        #expect(model.selectedSeason == "2027")

        // 2026 is no longer the latest season, so it has to be asked for by name.
        model.selectedSeason = "2026"
        await model.loadIfStale()
        #expect(requests.last == Request(team: "Tulsa", season: "2026"))
    }

    @Test func currentSeasonIsNotFetchedAgainUntilItIsStale() async {
        var clock = Date.now
        var fetchCount = 0
        let model = makeModel(
            fetchHistory: { _, _ in
                fetchCount += 1
                return Self.history()
            },
            now: { clock }
        )
        await model.loadIfStale()

        clock += RankingsSnapshot.maxAge - 1
        await model.loadIfStale()
        #expect(fetchCount == 1)

        clock += 2
        await model.loadIfStale()
        #expect(fetchCount == 2)
    }

    @Test func pointingAtTheChartSelectsTheNearestDayUntilLetGo() async throws {
        let model = makeModel()
        await model.load()
        try #require(model.series.points.count == 3)
        let secondDay = model.series.points[1]
        // With nothing pointed at, the readout shows the latest day with a ranking.
        #expect(model.focusedPoint == model.series.points[2])

        model.rawSelectedDate = secondDay.date + 60 * 60

        #expect(model.selectedPoint == secondDay)
        #expect(model.focusedPoint == secondDay)

        model.rawSelectedDate = nil

        #expect(model.selectedPoint == nil)
        #expect(model.focusedPoint == model.series.points[2])
    }

    @Test func selectionFollowsTheDataWhenItIsReplaced() async throws {
        let model = makeModel()
        await model.load()
        try #require(model.series.points.count == 3)
        model.rawSelectedDate = model.series.points[2].date
        #expect(model.selectedPoint?.ranking == 60)

        model.stat = "TotalDefense"
        #expect(model.selectedPoint?.ranking == 12)

        // A day of the old team's season can't stay selected once it is gone.
        model.team = "SMU"
        #expect(model.selectedPoint == nil)
    }
}
