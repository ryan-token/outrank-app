//
//  TeamRankingsModelTests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct TeamRankingsModelTests {
    private let rankings = ["ScoringOffense": 3, "BlockedKicks": 40, "TotalDefense": 12]

    @Test func chosenTeamIsRestoredOnNextLaunch() {
        let defaults = makeIsolatedDefaults()
        TeamRankingsModel(defaults: defaults) { _ in .stub() }.team = "SMU"

        let relaunched = TeamRankingsModel(defaults: defaults) { _ in .stub() }

        #expect(relaunched.team == "SMU")
    }

    @Test func changingTeamDropsThePreviousTeamsRankings() async {
        let model = TeamRankingsModel(defaults: makeIsolatedDefaults()) { _ in .stub(rankings) }
        await model.load()

        model.team = "SMU"

        #expect(model.sortedRankings.isEmpty)
        #expect(model.ranking(forStat: "TotalDefense") == nil)
        #expect(model.lastUpdated == nil)
        #expect(model.isAwaitingFirstLoad)
    }

    @Test func loadGivesEveryStatARowWhetherOrNotTheTeamIsRankedInIt() async throws {
        var requestedTeams: [String] = []
        let scrapedAt = Date(timeIntervalSince1970: 1_792_764_120)
        let model = TeamRankingsModel(defaults: makeIsolatedDefaults()) { team in
            requestedTeams.append(team)
            return .stub(rankings, scrapedAt: scrapedAt)
        }

        let loaded = await model.load()

        #expect(loaded)
        #expect(requestedTeams == [TeamRankingsModel.defaultTeam])
        #expect(model.sortedRankings.map(\.id) == AllStats.all)
        let blockedKicks = try #require(model.sortedRankings.first { $0.id == "BlockedKicks" })
        #expect(blockedKicks.title == "Blocked Kicks")
        #expect(blockedKicks.ranking == 40)
        // The API leaves out stats the team has no ranking in.
        let fumblesLost = try #require(model.sortedRankings.first { $0.id == "FumblesLost" })
        #expect(fumblesLost.ranking == nil)
        #expect(model.ranking(forStat: "TotalDefense") == 12)
        #expect(model.lastUpdated == scrapedAt)
        #expect(model.loadFailed == false)
    }

    @Test func statTheAppDoesNotKnowStillGetsARow() async throws {
        let model = TeamRankingsModel(defaults: makeIsolatedDefaults()) { _ in .stub(["BrandNewStat": 5]) }

        await model.load()

        let newStat = try #require(model.sortedRankings.first { $0.id == "BrandNewStat" })
        #expect(newStat.title == "Brand New Stat")
        #expect(model.sortedRankings.count == AllStats.all.count + 1)
    }

    @Test func changingTheSortOrderResortsAndBumpsTheRevision() async {
        let model = TeamRankingsModel(defaults: makeIsolatedDefaults()) { _ in .stub(rankings) }
        await model.load()
        let revision = model.revision

        model.sortMethod = .byRankingAscending

        #expect(model.sortedRankings.prefix(3).map(\.ranking) == [3, 12, 40])
        #expect(model.sortedRankings.dropFirst(3).allSatisfy { $0.ranking == nil })
        #expect(model.revision > revision)
    }

    @Test func failedLoadIsReportedAndKeepsPreviousRankings() async {
        var shouldFail = false
        let model = TeamRankingsModel(defaults: makeIsolatedDefaults()) { _ in
            if shouldFail { throw StubError() }
            return .stub(rankings)
        }
        await model.load()

        shouldFail = true
        let loaded = await model.load()

        #expect(loaded == false)
        #expect(model.loadFailed)
        #expect(model.ranking(forStat: "ScoringOffense") == 3)
    }

    @Test func currentRankingsAreNotFetchedAgainUntilTheyAreStale() async {
        var clock = Date.now
        var fetchCount = 0
        let model = TeamRankingsModel(
            defaults: makeIsolatedDefaults(),
            fetch: { _ in
                fetchCount += 1
                return .stub(rankings)
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

    @Test func failedLoadIsRetriedEvenWhenRecent() async {
        var shouldFail = false
        var fetchCount = 0
        let model = TeamRankingsModel(defaults: makeIsolatedDefaults()) { _ in
            fetchCount += 1
            if shouldFail { throw StubError() }
            return .stub(rankings)
        }
        await model.loadIfStale()
        shouldFail = true
        await model.load()

        shouldFail = false
        let loaded = await model.loadIfStale()

        #expect(loaded)
        #expect(fetchCount == 3)
        #expect(model.loadFailed == false)
    }

    @Test func responseForAPreviousTeamIsIgnored() async {
        let reference = ModelReference<TeamRankingsModel>()
        let model = TeamRankingsModel(defaults: makeIsolatedDefaults()) { _ in
            // The user picks another team while this request is in flight.
            reference.model?.team = "SMU"
            return .stub(["ScoringOffense": 1])
        }
        reference.model = model

        let loaded = await model.load()

        #expect(loaded == false)
        #expect(model.sortedRankings.isEmpty)
    }

    @Test func cancelledLoadIsNotReportedAsAFailure() async {
        let model = TeamRankingsModel(defaults: makeIsolatedDefaults()) { _ in
            // SwiftUI cancels the task when the view disappears or the team changes.
            withUnsafeCurrentTask { $0?.cancel() }
            throw CancellationError()
        }

        let loaded = await Task { await model.load() }.value

        #expect(loaded == false)
        #expect(model.loadFailed == false)
    }
}
