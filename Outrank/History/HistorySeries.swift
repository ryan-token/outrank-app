//
//  HistorySeries.swift
//  Outrank
//

import Foundation

/// One stat's rankings and values across a season, prepared for the chart.
///
/// Built when the history or the chosen stat changes, so drawing the chart and following
/// a selection never sort, scan, or summarize inside a view update.
nonisolated struct HistorySeries: Equatable, Sendable {
    /// The stat's readable name.
    let title: String

    /// One point for each day of the season, oldest first.
    let points: [HistoryPoint]

    /// Ranked days with no ranked day on either side. A line needs two points to draw,
    /// so these are plotted as dots instead.
    let isolatedPoints: [HistoryPoint]

    /// The most recent day with a ranking, or `nil` when the team was never ranked.
    let latest: HistoryPoint?

    /// A day the team held its best ranking of the season, and one it held its worst.
    let best: HistoryPoint?
    let worst: HistoryPoint?

    /// The chart's ranking scale, the same for every team and stat so switching between
    /// them compares like with like. It runs from 1st to last place in the FBS field (or
    /// to the series' own worst ranking, should the field outgrow this version's team
    /// list), with a little room past each end so a line there isn't drawn on the edge.
    let scaleDomain: ClosedRange<Double>

    /// The rankings the chart's scale labels.
    let axisRankings: [Double]

    /// How far down the scale the better half of the field reaches, from 0 at the top to
    /// 1 at the bottom. The chart changes color here, the way rankings do everywhere else.
    let topHalfFraction: Double

    static let empty = HistorySeries(title: "", days: [], rankings: [])

    /// How many places the scale extends past 1st and past last place.
    private static let scalePadding = 3.0

    /// - Parameters:
    ///   - days: The season's days.
    ///   - rankings: The team's ranking on each of `days`, lined up by position. Any past
    ///     the end of `days` are ignored.
    ///   - values: The stat value behind each of `rankings`, lined up the same way. Days
    ///     past its end have none, so a season with no values can pass nothing.
    ///   - valueFormat: How to write the values out.
    init(
        title: String,
        days: [Date],
        rankings: [Int?],
        values: [Double?] = [],
        valueFormat: StatValueFormat = .unlisted
    ) {
        // Put in date order here rather than trusted to arrive in it: the chart draws
        // its line through the points in this order, and `point(nearest:)` searches it.
        let points = zip(days, rankings).enumerated()
            .map { index, day in
                let value = values.indices.contains(index) ? values[index] : nil
                return HistoryPoint(
                    date: day.0,
                    ranking: day.1,
                    valueDescription: value.map(valueFormat.string(for:))
                )
            }
            .sorted { $0.date < $1.date }
        let ranked = points.compactMap { point in
            point.ranking.map { (point: point, ranking: $0) }
        }

        self.title = title
        self.points = points
        isolatedPoints = Self.isolated(points)
        latest = ranked.last?.point
        best = ranked.min { $0.ranking < $1.ranking }?.point
        worst = ranked.max { $0.ranking < $1.ranking }?.point

        let lastPlace = max(AllTeams.all.count, worst?.ranking ?? 0)
        let scaleDomain = (1 - Self.scalePadding)...(Double(lastPlace) + Self.scalePadding)
        self.scaleDomain = scaleDomain
        axisRankings = [1] + stride(from: 25, through: lastPlace, by: 25).map(Double.init)
        // The boundary sits halfway between the last top-half ranking and the first
        // bottom-half one.
        topHalfFraction = (Double(RankingStyle.goodRankingCutoff) + 0.5 - scaleDomain.lowerBound)
            / (scaleDomain.upperBound - scaleDomain.lowerBound)
    }

    /// The ranked points with no ranked day on either side.
    private static func isolated(_ points: [HistoryPoint]) -> [HistoryPoint] {
        points.indices.compactMap { index in
            let hasRankedNeighbor = [index - 1, index + 1].contains { neighbor in
                points.indices.contains(neighbor) && points[neighbor].ranking != nil
            }
            return points[index].ranking != nil && !hasRankedNeighbor ? points[index] : nil
        }
    }

    /// The day nearest to `date`, for following a selection across the chart. Dates
    /// outside the season clamp to its first or last day, and a date exactly between two
    /// days goes to the earlier one. Days without a ranking count, so pointing at a gap
    /// says the team wasn't ranked rather than jumping to a day when it was.
    func point(nearest date: Date) -> HistoryPoint? {
        guard let first = points.first, let last = points.last else { return nil }

        // Binary search for the first day on or after `date`.
        var low = points.startIndex
        var high = points.endIndex
        while low < high {
            let middle = low + (high - low) / 2
            if points[middle].date < date {
                low = middle + 1
            } else {
                high = middle
            }
        }

        if low == points.startIndex { return first }
        if low == points.endIndex { return last }

        let earlier = points[low - 1]
        let later = points[low]
        return date.timeIntervalSince(earlier.date) <= later.date.timeIntervalSince(date) ? earlier : later
    }

    /// The days of a season, parsed from the API's `yyyy-MM-dd` strings as the start of each
    /// day in `timeZone`, so each lands on the day it names wherever the user is.
    ///
    /// Every day the backend sends is plotted: it decides where a season ends. The result
    /// is always a leading run of `dates`, which keeps it lined up by position with the
    /// rankings recorded for them.
    static func days(from dates: [String], timeZone: TimeZone) -> [Date] {
        let strategy = Date.ISO8601FormatStyle(timeZone: timeZone).year().month().day()

        var days: [Date] = []
        days.reserveCapacity(dates.count)
        for date in dates {
            guard let day = try? Date(date, strategy: strategy) else { break }
            days.append(day)
        }
        return days
    }
}
