//
//  HistoryStatSearchTests.swift
//  OutrankTests
//

import Testing
@testable import Outrank

struct HistoryStatSearchTests {
    @Test func searchGoesByTheNamesThePickerShows() {
        let model = HistoryModel(defaults: makeIsolatedDefaults())

        // "ScoringOffense" has no space in it; the name on screen does.
        #expect(model.stats(matching: " scoring off ") == ["ScoringOffense"])
        #expect(model.stats(matching: "") == model.stats)
        #expect(model.stats(matching: "Zzz").isEmpty)
    }
}
