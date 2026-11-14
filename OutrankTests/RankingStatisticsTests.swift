//
//  RankingStatisticsTests.swift
//  OutrankTests
//

import Testing
@testable import Outrank

struct RankingStatisticsTests {
    @Test func noRankingsHasNoAverage() {
        #expect(RankingStatistics.simpleAverage(of: [Int]()) == nil)
    }

    @Test(arguments: [
        ([10, 21], 16), // 15.5 rounds up
        ([10, 12, 21], 14) // 14.33 rounds down
    ])
    func averageRoundsToTheNearestRanking(rankings: [Int], expected: Int) {
        #expect(RankingStatistics.simpleAverage(of: rankings) == expected)
    }
}
