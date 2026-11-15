//
//  HistoryValueScaleTests.swift
//  OutrankTests
//

import Testing
@testable import Outrank

struct HistoryValueScaleTests {
    // A value only moves when a team plays, so a season's first weeks hold one value or a
    // few close ones. Whatever they are, the scale has to label round numbers that read
    // differently from one another, and hold every value between its first and last.
    @Test(arguments: [
        ([310.2, 534.7, 480.0], StatValueFormat.decimal(places: 1), ["300", "400", "500", "600"]),
        ([33.6], .decimal(places: 1), ["33.5", "33.6", "33.7"]),
        ([33.6, 33.6, 33.7], .decimal(places: 1), ["33.5", "33.6", "33.7", "33.8"]),
        ([0.58, 0.589], .percent, ["58%", "58.5%", "59%"]),
        ([13, 13, 14], .count, ["12", "13", "14", "15"]),
        ([0.3, -1.2], .decimal(places: 2), ["-1.5", "-1", "-0.5", "0", "0.5"])
    ])
    func scaleLabelsRoundNumbersAroundTheValues(values: [Double], format: StatValueFormat, labels: [String]) throws {
        let scale = try #require(HistoryValueScale(values: values, smallestStep: format.smallestStep))

        #expect(scale.ticks.map(format.axisLabel(for:)) == labels)
        #expect(values.allSatisfy(scale.domain.contains))
        #expect(scale.ticks.allSatisfy(scale.domain.contains))
    }

    @Test func seasonWithoutValuesHasNoScale() {
        #expect(HistoryValueScale(values: [], smallestStep: 0.1) == nil)
    }
}
