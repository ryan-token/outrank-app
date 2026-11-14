//
//  StatRankingsModelTests.swift
//  OutrankTests
//

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

    @Test func teamTheAppDoesNotKnowStillGetsARow() async {
        let model = StatRankingsModel { _ in .stub(["New Program": 1]) }

        await model.load(stat: "ScoringOffense")

        #expect(model.entries.first?.title == "New Program")
        #expect(model.entries.count == AllTeams.all.count + 1)
    }

    @Test func failedLoadIsReported() async {
        let model = StatRankingsModel { _ in throw StubError() }

        await model.load(stat: "ScoringOffense")

        #expect(model.loadFailed)
        #expect(model.entries.isEmpty)
    }
}
