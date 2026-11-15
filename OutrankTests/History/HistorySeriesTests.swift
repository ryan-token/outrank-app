//
//  HistorySeriesTests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct HistorySeriesTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Chicago") ?? .gmt
        return calendar
    }()

    private static let day: TimeInterval = 24 * 60 * 60
    private static let firstDay = Date(timeIntervalSince1970: 1_788_930_000)

    /// Consecutive days, one for each ranking.
    private func makeSeries(_ rankings: [Int?]) -> HistorySeries {
        let days = rankings.indices.map { Self.firstDay + Double($0) * Self.day }
        return HistorySeries(title: "Scoring Offense", days: days, rankings: rankings)
    }

    @Test func daysAreLocalCalendarDaysForAsLongAsTheBackendSendsThem() throws {
        let days = HistorySeries.days(from: ["2025-09-06", "2026-02-03"], timeZone: Self.calendar.timeZone)

        let kickoff = try #require(Self.calendar.date(from: DateComponents(year: 2025, month: 9, day: 6)))
        // The backend decides where a season ends, such as after a title game in February.
        let titleGame = try #require(Self.calendar.date(from: DateComponents(year: 2026, month: 2, day: 3)))
        #expect(days == [kickoff, titleGame])
    }

    @Test func daysStopAtADateThatCannotBeReadSoTheyStayLinedUpWithRankings() {
        let days = HistorySeries.days(
            from: ["2025-09-06", "not a date", "2025-09-08"],
            timeZone: Self.calendar.timeZone
        )

        #expect(days.count == 1)
    }

    @Test func summaryComesFromTheDaysTheTeamWasRanked() {
        let series = makeSeries([nil, 40, 12, nil, 30, nil])

        #expect(series.latest == series.points[4])
        #expect(series.best == series.points[2])
        #expect(series.worst == series.points[1])
    }

    @Test func seasonWithoutARankingHasNoSummary() {
        let series = makeSeries([nil, nil])

        #expect(series.points.count == 2)
        #expect(series.latest == nil)
        #expect(series.best == nil)
        #expect(series.worst == nil)
    }

    @Test func unrankedDaysBreakTheLineAndLoneRankedDaysBecomeDots() {
        let series = makeSeries([5, nil, 7, nil, nil, 9, 10])

        // A day that isn't a number is where the chart lifts its pen.
        #expect(series.points.map(\.plottedRanking.isNaN) == [false, true, false, true, true, false, false])
        #expect(series.isolatedPoints.map(\.ranking) == [5, 7])
    }

    @Test(arguments: [
        (-48.0, 0), // before the season clamps to its first day
        (5.0, 0),
        (12.0, 0), // exactly between two days goes to the earlier one
        (13.0, 1),
        (36.0, 1), // an unranked day can be pointed at too
        (37.0, 2),
        (500.0, 2) // after the season clamps to its last day
    ])
    func nearestPoint(hoursIntoSeason: Double, expectedDay: Int) {
        let series = makeSeries([1, nil, 3])

        let point = series.point(nearest: Self.firstDay + hoursIntoSeason * 60 * 60)

        #expect(point == series.points[expectedDay])
    }

    @Test func emptySeriesHasNoNearestPoint() {
        #expect(HistorySeries.empty.point(nearest: Self.firstDay) == nil)
    }

    @Test func scaleCoversTheFieldAndChangesColorWhereRankingsDo() {
        let series = makeSeries([50])
        let scale = series.scaleDomain
        let cutoff = RankingStyle.goodRankingCutoff

        func position(of ranking: Int) -> Double {
            (Double(ranking) - scale.lowerBound) / (scale.upperBound - scale.lowerBound)
        }

        #expect(scale.contains(1))
        #expect(scale.contains(Double(AllTeams.all.count)))
        // The last green ranking sits above the boundary and the first red one below it.
        #expect(position(of: cutoff) < series.topHalfFraction)
        #expect(series.topHalfFraction < position(of: cutoff + 1))
    }

    @Test func rankingBeyondTheKnownFieldStretchesTheScale() {
        let ranking = AllTeams.all.count + 12

        let series = makeSeries([ranking])

        #expect(series.scaleDomain.contains(Double(ranking)))
    }
}
