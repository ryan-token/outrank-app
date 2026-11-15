//
//  ComparisonModelTests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct ComparisonModelTests {
    /// Tulsa has no Blocked Kicks ranking, which the API reports by leaving the stat out.
    private static let stubRankings: [String: [String: Int]] = [
        "Tulsa": ["ScoringOffense": 10, "TotalDefense": 30],
        "SMU": ["ScoringOffense": 20, "TotalDefense": 30, "BlockedKicks": 25]
    ]

    private func makeModel(defaults: UserDefaults = makeIsolatedDefaults()) -> ComparisonModel {
        ComparisonModel(defaults: defaults) { team in
            .stub(Self.stubRankings[team] ?? [:])
        }
    }

    @Test func subscriptReadsAndWritesEachSlot() {
        let defaults = makeIsolatedDefaults()
        let model = makeModel(defaults: defaults)

        model[team: .teamTwo] = "Rice"

        #expect(model[team: .teamOne] == "Tulsa")
        #expect(model.teamTwo == "Rice")
        #expect(defaults.string(forKey: ComparisonModel.teamTwoKey) == "Rice")
    }

    @Test func pickingANewTeamDropsTheSlotsOldRankings() async {
        let model = makeModel()
        await model.loadBothTeams()

        model[team: .teamTwo] = "Rice"

        // Nothing of SMU's may show under Rice's name while Rice loads.
        #expect(model.average(for: .teamTwo) == nil)
        #expect(model.rows.allSatisfy { $0.teamTwoRanking == nil })
        #expect(model.average(for: .teamOne) == 20)
    }

    @Test func eachSlotAwaitsItsFirstLoadUntilItLoadsOrFails() async {
        let model = ComparisonModel(defaults: makeIsolatedDefaults()) { team in
            if team == "SMU" { throw StubError() }
            return .stub(Self.stubRankings[team] ?? [:])
        }
        #expect(model.isAwaitingFirstLoad(.teamOne))
        #expect(model.isAwaitingFirstLoad(.teamTwo))

        await model.loadBothTeams()
        #expect(model.isAwaitingFirstLoad(.teamOne) == false)
        // A failed load shows "Unknown", not a placeholder that never resolves.
        #expect(model.isAwaitingFirstLoad(.teamTwo) == false)

        model[team: .teamOne] = "Rice"
        #expect(model.isAwaitingFirstLoad(.teamOne))
    }

    @Test func swappedTeamsAreNotFetchedAgain() async {
        var fetchCount = 0
        let model = ComparisonModel(defaults: makeIsolatedDefaults()) { team in
            fetchCount += 1
            return .stub(Self.stubRankings[team] ?? [:])
        }
        await model.loadStaleTeams()

        model.swapTeams()
        await model.loadStaleTeams()

        #expect(fetchCount == 2)
    }

    @Test func staleRankingsAreFetchedAgain() async {
        var clock = Date.now
        var fetchCount = 0
        let model = ComparisonModel(
            defaults: makeIsolatedDefaults(),
            fetch: { team in
                fetchCount += 1
                return .stub(Self.stubRankings[team] ?? [:])
            },
            now: { clock }
        )
        await model.loadStaleTeams()

        clock += RankingsSnapshot.maxAge - 1
        await model.loadStaleTeams()
        #expect(fetchCount == 2)

        clock += 2
        await model.loadStaleTeams()
        #expect(fetchCount == 4)
    }

    @Test func failedTeamIsFetchedAgainEvenWhenRecent() async {
        var shouldFail = true
        let model = ComparisonModel(defaults: makeIsolatedDefaults()) { team in
            if shouldFail, team == "SMU" { throw StubError() }
            return .stub(Self.stubRankings[team] ?? [:])
        }
        await model.loadStaleTeams()

        shouldFail = false
        await model.loadStaleTeams()

        #expect(model.loadFailed == false)
        #expect(model.average(for: .teamTwo) == 25)
    }

    @Test func rowsLineUpBothTeamsInEveryStat() async throws {
        let model = makeModel()

        await model.loadBothTeams()

        #expect(model.rows.map(\.id) == AllStats.all)
        let scoring = try #require(model.rows.first { $0.id == "ScoringOffense" })
        #expect(scoring.title == "Scoring Offense")
        #expect(scoring.teamOneRanking == 10)
        #expect(scoring.teamTwoRanking == 20)
        // A stat only one team is ranked in still shows that team's ranking.
        let blockedKicks = try #require(model.rows.first { $0.id == "BlockedKicks" })
        #expect(blockedKicks.teamOneRanking == nil)
        #expect(blockedKicks.teamTwoRanking == 25)
        #expect(model.average(for: .teamOne) == 20)
        #expect(model.average(for: .teamTwo) == 25)
        #expect(model.loadFailed == false)
    }

    @Test func swapExchangesTeamsAndTheirLoadedData() async throws {
        let defaults = makeIsolatedDefaults()
        let model = makeModel(defaults: defaults)
        await model.loadBothTeams()

        model.swapTeams()

        #expect(model.teamOne == "SMU")
        #expect(model.teamTwo == "Tulsa")
        #expect(model.average(for: .teamOne) == 25)
        let scoring = try #require(model.rows.first { $0.id == "ScoringOffense" })
        #expect(scoring.teamOneRanking == 20)
        #expect(scoring.teamTwoRanking == 10)
        #expect(defaults.string(forKey: ComparisonModel.teamOneKey) == "SMU")
        #expect(defaults.string(forKey: ComparisonModel.teamTwoKey) == "Tulsa")
    }

    @Test func sortingFollowsTeamOneRankings() async {
        let model = makeModel()
        await model.loadBothTeams()

        model.sortMethod = .byRankingAscending

        #expect(model.rows.prefix(2).map(\.id) == ["ScoringOffense", "TotalDefense"])
        #expect(model.rows.dropFirst(2).allSatisfy { $0.teamOneRanking == nil })
    }

    @Test func oneTeamFailingLeavesTheOthersRankingsOnScreen() async throws {
        let model = ComparisonModel(defaults: makeIsolatedDefaults()) { team in
            if team == "SMU" { throw StubError() }
            return .stub(["ScoringOffense": 1])
        }

        await model.loadBothTeams()

        #expect(model.loadFailed)
        let scoring = try #require(model.rows.first { $0.id == "ScoringOffense" })
        #expect(scoring.teamOneRanking == 1)
        #expect(scoring.teamTwoRanking == nil)
        #expect(model.average(for: .teamTwo) == nil)
    }

    @Test func responseForATeamNoLongerInTheSlotIsIgnored() async {
        let reference = ModelReference<ComparisonModel>()
        let model = ComparisonModel(defaults: makeIsolatedDefaults()) { _ in
            // The teams are swapped while this request is in flight.
            reference.model?.swapTeams()
            return .stub(["ScoringOffense": 1])
        }
        reference.model = model

        await model.load(.teamOne)

        #expect(model.rows.isEmpty)
        #expect(model.average(for: .teamOne) == nil)
        #expect(model.average(for: .teamTwo) == nil)
    }
}
