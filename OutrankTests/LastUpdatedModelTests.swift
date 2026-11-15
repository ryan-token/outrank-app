//
//  LastUpdatedModelTests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct LastUpdatedModelTests {
    private let scrapedAt = Date(timeIntervalSince1970: 1_800_000_000)

    @Test func currentTimeIsNotFetchedAgainUntilItIsStale() async {
        var clock = Date.now
        var fetchCount = 0
        let model = LastUpdatedModel(
            fetchMetadata: { [scrapedAt] in
                fetchCount += 1
                return RankingsMetadata(seasons: [], scrapedAt: scrapedAt)
            },
            now: { clock }
        )
        await model.loadIfStale()
        #expect(model.date == scrapedAt)

        clock += RankingsSnapshot.maxAge - 1
        await model.loadIfStale()
        #expect(fetchCount == 1)

        clock += 2
        await model.loadIfStale()
        #expect(fetchCount == 2)
    }

    @Test func failedLoadKeepsTheLastKnownTimeAndIsTriedAgain() async {
        var clock = Date.now
        var fetchCount = 0
        let model = LastUpdatedModel(
            fetchMetadata: { [scrapedAt] in
                fetchCount += 1
                if fetchCount == 1 {
                    return RankingsMetadata(seasons: [], scrapedAt: scrapedAt)
                }
                throw StubError()
            },
            now: { clock }
        )
        await model.loadIfStale()

        clock += RankingsSnapshot.maxAge + 1
        await model.loadIfStale()
        await model.loadIfStale()

        #expect(model.date == scrapedAt)
        #expect(fetchCount == 3)
    }
}
