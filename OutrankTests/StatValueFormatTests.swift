//
//  StatValueFormatTests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct StatValueFormatTests {
    // The backend sends a plain number for every stat, so these are the ways one has to
    // come out differently: a percentage from a fraction, decimals kept on a round number,
    // and none invented for a stat the app doesn't list.
    @Test(arguments: [
        (StatValueFormat.count, 13.0, "13"),
        (.decimal(places: 1), 373.0, "373.0"),
        (.decimal(places: 2), 0.3, "0.30"),
        (.decimal(places: 2), -1.2, "-1.20"),
        (.rating(places: 2), 158.4, "158.40"),
        (.percent, 0.589, "58.9%"),
        (.percent, 1.0, "100.0%"),
        (.minutes, 36.7, "36.7 min"),
        (.unlisted, 12.5, "12.5"),
        (.unlisted, 4.0, "4")
    ])
    func valueReadsTheWayNcaaPrintsIt(format: StatValueFormat, value: Double, expected: String) {
        #expect(format.string(for: value) == expected)
    }

    // A rating is worked out by formula, and calling it an average would be wrong.
    @Test(arguments: ["TeamPassingEfficiency", "TeamPassingEfficiencyDefense"])
    func passingEfficiencyIsARating(stat: String) {
        #expect(AllStats.valueFormat(for: stat) == .rating(places: 2))
    }

    // The formats are keyed by stat name in a table of their own, where a misspelled or
    // forgotten stat would quietly show the wrong number of decimals.
    @Test func everyStatTheAppListsHasAFormat() {
        #expect(AllStats.all.filter { AllStats.valueFormat(for: $0) == .unlisted } == [])
    }
}
