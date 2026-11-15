//
//  StatRankingsModelTests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct StatRankingsModelTests {
    @Test func rankedTeamsComeFirstBestToWorstAndEveryOtherTeamStillGetsARow() async {
        var requestedStats: [String] = []
        let model = StatRankingsModel { stat in
            requestedStats.append(stat)
            return .stub(["Texas A&M": 9, "Miami (FL)": 2, "Tulsa": 9])
        }

        await model.load(stat: "ScoringOffense")

        #expect(requestedStats == ["ScoringOffense"])
        #expect(model.entries.prefix(3).map(\.title) == ["Miami (FL)", "Texas A&M", "Tulsa"])
        #expect(model.entries.count == AllTeams.all.count)
        #expect(model.entries.dropFirst(3).allSatisfy { $0.ranking == nil })
        #expect(model.loadFailed == false)
    }

    @Test func rowsShowEachTeamsValueTheWayTheStatWritesIt() async {
        let model = StatRankingsModel { _ in
            .stub(["Houston": 1, "Tulsa": 90, "UTEP": 138], values: ["Houston": 0.589, "Tulsa": 0.331])
        }

        await model.load(stat: "ThirdDownConversionPct")

        // UTEP is ranked, but arrived without a value.
        #expect(model.entries.prefix(3).map(\.value) == ["58.9%", "33.1%", nil])
    }

    @Test func teamTheAppDoesNotKnowStillGetsARow() async {
        let model = StatRankingsModel { _ in .stub(["New Program": 1]) }

        await model.load(stat: "ScoringOffense")

        #expect(model.entries.first?.title == "New Program")
        #expect(model.entries.count == AllTeams.all.count + 1)
    }

    @Test func currentRankingsAreNotFetchedAgainUntilTheyAreStale() async {
        var clock = Date.now
        var fetchCount = 0
        let model = StatRankingsModel(
            fetch: { _ in
                fetchCount += 1
                return .stub()
            },
            now: { clock }
        )
        await model.loadIfStale(stat: "ScoringOffense")

        clock += RankingsSnapshot.maxAge - 1
        await model.loadIfStale(stat: "ScoringOffense")
        #expect(fetchCount == 1)

        clock += 2
        await model.loadIfStale(stat: "ScoringOffense")
        #expect(fetchCount == 2)
    }

    @Test func failedLoadIsReported() async {
        let model = StatRankingsModel { _ in throw StubError() }

        await model.load(stat: "ScoringOffense")

        #expect(model.loadFailed)
        #expect(model.entries.isEmpty)
    }
}
