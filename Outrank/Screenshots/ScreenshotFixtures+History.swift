//
//  ScreenshotFixtures+History.swift
//  Outrank
//

#if DEBUG
import Foundation

// Frozen API data rather than logic, so its length isn't a design smell.
// swiftlint:disable file_length

nonisolated extension ScreenshotFixtures {
    /// Tulsa's 2026 season through November 15, the day the other fixtures were frozen.
    static func teamHistory(for team: String, season: String?) async throws -> TeamHistory {
        guard team == historyTeam, season == nil || season == historySeason else {
            throw FixtureError.missing("\(team) \(season ?? "latest season")")
        }
        return TeamHistory(season: historySeason, dates: historyDates, ranks: historyRanks, values: historyValues)
    }

    static func metadata() async throws -> RankingsMetadata {
        RankingsMetadata(seasons: ["2021", "2022", "2023", "2024", "2025", historySeason], scrapedAt: scrapedAt)
    }

    private static let historyTeam = "Tulsa"
    private static let historySeason = "2026"

    private static let historyDates = [
        "2026-09-08", "2026-09-09", "2026-09-11", "2026-09-13", "2026-09-14", "2026-09-15", "2026-09-16", "2026-09-17",
        "2026-09-18", "2026-09-19", "2026-09-20", "2026-09-21", "2026-09-22", "2026-09-24", "2026-09-25", "2026-09-27",
        "2026-09-28", "2026-09-30", "2026-10-01", "2026-10-02", "2026-10-03", "2026-10-05", "2026-10-06", "2026-10-07",
        "2026-10-08", "2026-10-10", "2026-10-12", "2026-10-13", "2026-10-15", "2026-10-16", "2026-10-17", "2026-10-18",
        "2026-10-19", "2026-10-20", "2026-10-21", "2026-10-22", "2026-10-23", "2026-10-24", "2026-10-26", "2026-10-28",
        "2026-10-29", "2026-10-30", "2026-10-31", "2026-11-01", "2026-11-02", "2026-11-03", "2026-11-04", "2026-11-05",
        "2026-11-06", "2026-11-07", "2026-11-09", "2026-11-10", "2026-11-11", "2026-11-12", "2026-11-13", "2026-11-14",
        "2026-11-15"
    ]

    /// The value behind each ranking below, lined up with `historyDates`. The backend began
    /// recording values late in the season, so earlier dates have none.
    private static let historyValues: [String: [Double?]] = [
        "BlockedKicksAllowed": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1
        ],
        "BlockedPuntsAllowed": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1
        ],
        "CompletionPercentage": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.628
        ],
        "FewestPenalties": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 49
        ],
        "FewestPenaltiesPerGame": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 4.9
        ],
        "FewestPenaltyYards": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 431
        ],
        "FewestPenaltyYardsPerGame": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 43.1
        ],
        "FirstDownsDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 212
        ],
        "FirstDownsOffense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 197
        ],
        "FourthDownConversionPct": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.75
        ],
        "FourthDownConversionPctDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.463
        ],
        "FumblesLost": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 4
        ],
        "FumblesRecovered": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 8
        ],
        "KickoffReturnDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 20.63
        ],
        "KickoffReturns": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 21
        ],
        "NetPunting": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 37.98
        ],
        "PassesHadIntercepted": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 4
        ],
        "PassesIntercepted": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 10
        ],
        "PassingOffense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 234
        ],
        "PassingYardsAllowed": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 208.6
        ],
        "PassingYardsPerCompletion": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 11.47
        ],
        "PuntReturnDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 5.79
        ],
        "PuntReturns": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 5.56
        ],
        "RedZoneDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.737
        ],
        "RedZoneOffense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.895
        ],
        "RushingDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 178.1
        ],
        "RushingOffense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 168.1
        ],
        "SacksAllowed": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1.5
        ],
        "ScoringDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 22.6
        ],
        "ScoringOffense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 33.6
        ],
        "TacklesForLossAllowed": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 4.9
        ],
        "TeamPassingEfficiency": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 141.1
        ],
        "TeamPassingEfficiencyDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 121.28
        ],
        "TeamSacks": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 2.7
        ],
        "TeamTacklesForLoss": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 5.5
        ],
        "ThirdDownConversionPct": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.331
        ],
        "ThirdDownConversionPctDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.353
        ],
        "TimeOfPossession": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 27.7
        ],
        "TotalDefense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 386.7
        ],
        "TotalOffense": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 402.1
        ],
        "TurnoverMargin": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1
        ],
        "TurnoversGained": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 18
        ],
        "TurnoversLost": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 8
        ],
        "WinningPercentage": [
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.6
        ]
    ]

    /// Each stat's rankings, lined up with `historyDates`.
    private static let historyRanks: [String: [Int?]] = [
        "BlockedKicksAllowed": [
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 76, 72, 72, 72, 72, 71, 67, 67, 67, 66, 66, 66, 66, 62, 62, 62, 62, 62, 62, 61
        ],
        "BlockedPuntsAllowed": [
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
            1, 112, 109, 109, 109, 109, 108, 106, 108, 106, 105, 105, 105, 105, 102, 102, 102, 102, 102, 102, 101
        ],
        "CompletionPercentage": [
            44, 45, 45, 44, 105, 105, 105, 105, 105, 105, 105, 105, 105, 105, 105, 112, 112, 112, 112, 112, 111, 111,
            111, 111, 110, 111, 113, 113, 115, 115, 115, 101, 101, 101, 100, 100, 100, 90, 90, 90, 90, 90, 90, 89, 89,
            89, 89, 90, 90, 90, 71, 71, 71, 72, 71, 71, 71
        ],
        "FewestPenalties": [
            97, 97, 97, 93, 57, 57, 57, 57, 58, 58, 58, 56, 56, 56, 56, 49, 49, 49, 49, 49, 73, 37, 37, 37, 37, 34, 21,
            21, 20, 20, 19, 29, 29, 29, 29, 29, 29, 52, 27, 27, 27, 27, 27, 17, 17, 17, 16, 16, 16, 16, 11, 11, 11, 11,
            11, 10, 19
        ],
        "FewestPenaltiesPerGame": [
            107, 108, 108, 109, 61, 61, 61, 61, 62, 62, 62, 62, 62, 62, 62, 46, 46, 46, 46, 46, 33, 30, 30, 30, 30, 30,
            19, 19, 18, 18, 17, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 20, 20, 20, 19, 19, 19, 19, 11, 11, 11,
            11, 11, 11, 19
        ],
        "FewestPenaltyYards": [
            121, 121, 122, 119, 89, 89, 89, 89, 88, 88, 88, 86, 86, 86, 86, 61, 61, 61, 61, 88, 86, 52, 52, 52, 50, 47,
            34, 34, 31, 30, 29, 50, 50, 50, 48, 48, 47, 59, 30, 30, 30, 29, 29, 21, 21, 21, 20, 20, 20, 20, 14, 14, 14,
            14, 13, 12, 20
        ],
        "FewestPenaltyYardsPerGame": [
            129, 130, 130, 130, 97, 97, 97, 97, 97, 97, 97, 98, 98, 98, 98, 58, 58, 58, 58, 58, 41, 40, 40, 40, 40, 40,
            25, 25, 25, 25, 26, 33, 33, 33, 33, 33, 33, 26, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 15, 15, 15,
            15, 15, 15, 19
        ],
        "FirstDownsDefense": [
            114, 114, 114, 114, 114, 114, 114, 114, 112, 112, 112, 109, 109, 109, 109, 115, 115, 115, 115, 138, 138,
            128, 128, 128, 126, 122, 133, 133, 132, 131, 127, 132, 132, 132, 131, 131, 131, 137, 132, 130, 130, 129,
            129, 108, 108, 108, 106, 105, 105, 102, 98, 98, 98, 94, 90, 89, 109
        ],
        "FirstDownsOffense": [
            118, 119, 119, 120, 115, 115, 115, 115, 115, 115, 115, 116, 116, 116, 116, 122, 122, 122, 122, 46, 49, 97,
            97, 97, 101, 102, 99, 99, 102, 103, 105, 88, 88, 88, 92, 92, 93, 42, 76, 76, 79, 81, 82, 112, 112, 112, 112,
            114, 114, 114, 79, 79, 79, 82, 85, 85, 81
        ],
        "FourthDownConversionPct": [
            1, 1, 1, 1, 38, 38, 38, 38, 38, 38, 38, 36, 36, 36, 36, 13, 13, 13, 13, 13, 9, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6,
            6, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 4, 5, 5, 5, 5, 5, 5, 5, 2, 2, 2, 2, 2, 2, 5
        ],
        "FourthDownConversionPctDefense": [
            62, 62, 62, 61, 31, 31, 31, 31, 32, 32, 32, 32, 32, 32, 32, 14, 14, 14, 14, 14, 33, 28, 28, 28, 27, 28, 38,
            38, 38, 38, 38, 31, 31, 31, 31, 31, 31, 40, 38, 38, 38, 38, 38, 40, 40, 40, 40, 40, 40, 40, 27, 27, 27, 28,
            29, 30, 46
        ],
        "FumblesLost": [
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 90, 90, 90, 90, 89, 89, 75, 75, 75, 74, 74, 66, 66, 66, 66, 64,
            50, 50, 50, 49, 49, 49, 47, 43, 42, 42, 41, 41, 28, 28, 28, 28, 28, 28, 27, 24, 24, 24, 23, 23, 23, 34
        ],
        "FumblesRecovered": [
            1, 1, 1, 1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 21, 21, 21, 21, 21, 7, 12, 12, 12, 13, 14, 2, 2, 2, 2, 3, 2, 2,
            2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 9, 9, 9, 9, 9, 9, 12
        ],
        "KickoffReturnDefense": [
            106, 106, 106, 107, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 112, 113, 113, 113, 113, 66, 65, 64,
            64, 64, 66, 65, 71, 71, 71, 71, 72, 49, 49, 49, 49, 49, 49, 39, 35, 35, 35, 34, 34, 30, 30, 30, 30, 30, 30,
            30, 53, 53, 53, 73, 73, 73, 84
        ],
        "KickoffReturns": [
            53, 54, 54, 56, 94, 94, 94, 94, 95, 95, 95, 94, 94, 94, 94, 17, 17, 17, 17, 33, 34, 35, 35, 35, 34, 36, 40,
            40, 40, 40, 40, 46, 46, 46, 46, 46, 46, 44, 47, 47, 48, 49, 50, 51, 51, 51, 51, 51, 51, 51, 54, 54, 54, 52,
            52, 52, 60
        ],
        "NetPunting": [
            65, 65, 65, 67, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 52, 52, 52, 52, 52, 52, 48, 48, 48, 48, 48, 50,
            50, 50, 50, 51, 45, 45, 45, 45, 45, 45, 75, 73, 73, 73, 72, 72, 75, 75, 75, 75, 75, 75, 75, 91, 91, 91, 90,
            90, 90, 102
        ],
        "PassesHadIntercepted": [
            75, 75, 75, 73, 48, 48, 48, 48, 47, 47, 47, 46, 46, 46, 46, 14, 14, 14, 14, 14, 13, 9, 9, 9, 9, 9, 7, 7, 7,
            7, 7, 7, 7, 7, 7, 7, 7, 15, 12, 12, 12, 12, 12, 8, 8, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 21
        ],
        "PassesIntercepted": [
            12, 12, 13, 15, 30, 30, 30, 30, 31, 31, 31, 33, 33, 33, 33, 29, 29, 29, 29, 29, 5, 11, 11, 11, 11, 11, 9, 9,
            9, 9, 10, 17, 17, 17, 17, 17, 17, 19, 27, 27, 27, 28, 28, 35, 35, 35, 35, 35, 35, 35, 22, 22, 22, 22, 23,
            23, 18
        ],
        "PassingOffense": [
            73, 74, 74, 75, 108, 108, 108, 108, 108, 108, 108, 108, 108, 108, 108, 115, 115, 115, 115, 115, 112, 111,
            111, 111, 111, 111, 97, 97, 98, 98, 98, 97, 97, 97, 97, 97, 97, 91, 88, 88, 88, 87, 87, 87, 87, 87, 86, 85,
            85, 85, 74, 74, 74, 74, 74, 74, 54
        ],
        "PassingYardsAllowed": [
            98, 99, 99, 99, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 124, 130, 132,
            132, 132, 132, 132, 111, 111, 111, 111, 111, 81, 81, 81, 81, 81, 81, 59, 55, 56, 55, 55, 53, 53, 53, 53, 53,
            53, 53, 53, 41, 41, 41, 41, 40, 40, 64
        ],
        "PassingYardsPerCompletion": [
            51, 52, 52, 52, 104, 104, 104, 104, 104, 104, 104, 105, 105, 105, 105, 116, 116, 116, 116, 124, 124, 127,
            127, 127, 128, 128, 118, 118, 118, 117, 115, 112, 112, 112, 112, 112, 112, 110, 112, 112, 112, 112, 112,
            109, 109, 109, 109, 109, 110, 110, 102, 102, 102, 102, 102, 102, 85
        ],
        "PuntReturnDefense": [
            83, 82, 82, 82, 54, 54, 54, 54, 52, 52, 52, 49, 49, 49, 49, 35, 35, 35, 35, 35, 45, 37, 37, 38, 39, 39, 31,
            31, 31, 31, 31, 27, 27, 27, 27, 27, 27, 31, 28, 28, 28, 28, 28, 27, 27, 28, 28, 28, 28, 29, 25, 25, 25, 25,
            25, 25, 39
        ],
        "PuntReturns": [
            131, 132, 132, 133, 133, 133, 133, 133, 135, 135, 135, 135, 135, 135, 135, 107, 107, 107, 108, 108, 108,
            110, 110, 110, 110, 110, 119, 119, 119, 119, 117, 117, 117, 117, 119, 119, 119, 127, 127, 127, 127, 127,
            127, 128, 128, 128, 128, 128, 128, 128, 121, 121, 121, 120, 120, 121, 118
        ],
        "RedZoneDefense": [
            24, 24, 24, 25, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 37, 32, 32, 32, 32, 32, 19, 19, 19, 19, 20,
            25, 25, 25, 24, 24, 24, 35, 26, 26, 26, 26, 26, 29, 29, 29, 30, 30, 30, 30, 31, 31, 31, 31, 30, 30, 13
        ],
        "RedZoneOffense": [
            119, 120, 120, 122, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 134, 130, 130, 130, 130, 130, 88, 89,
            89, 90, 90, 89, 55, 55, 55, 55, 54, 56, 56, 56, 56, 56, 57, 66, 64, 64, 64, 63, 63, 60, 60, 60, 59, 60, 60,
            60, 43, 43, 43, 43, 43, 43, 34
        ],
        "RushingDefense": [
            77, 77, 77, 78, 42, 42, 42, 42, 42, 41, 41, 40, 40, 40, 40, 37, 37, 37, 37, 37, 74, 62, 62, 62, 62, 62, 110,
            110, 110, 110, 111, 121, 121, 121, 122, 122, 122, 131, 130, 130, 130, 130, 130, 130, 130, 130, 130, 130,
            130, 130, 124, 124, 124, 123, 121, 121, 109
        ],
        "RushingOffense": [
            88, 89, 89, 91, 53, 53, 53, 53, 53, 53, 53, 52, 52, 52, 52, 45, 45, 45, 45, 45, 52, 55, 55, 55, 56, 56, 65,
            65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 67, 65, 65, 65, 66, 66, 67, 67, 67, 67, 67, 67, 67, 55, 55, 55, 56,
            56, 55, 53
        ],
        "SacksAllowed": [
            1, 1, 1, 1, 77, 77, 77, 77, 76, 76, 76, 77, 77, 77, 77, 52, 52, 51, 51, 50, 50, 45, 45, 45, 45, 46, 38, 38,
            38, 38, 38, 35, 35, 35, 35, 35, 35, 44, 39, 39, 39, 38, 38, 31, 31, 31, 31, 32, 32, 31, 25, 25, 25, 25, 25,
            25, 37
        ],
        "ScoringDefense": [
            38, 38, 38, 37, 35, 35, 35, 35, 34, 34, 34, 33, 33, 33, 33, 24, 24, 24, 24, 24, 53, 52, 52, 52, 52, 52, 67,
            67, 67, 67, 67, 60, 60, 60, 60, 60, 60, 73, 71, 71, 71, 71, 71, 67, 67, 67, 67, 68, 68, 68, 51, 51, 51, 50,
            52, 51, 54
        ],
        "ScoringOffense": [
            83, 83, 84, 85, 103, 103, 103, 103, 103, 103, 103, 103, 103, 103, 103, 100, 100, 100, 100, 100, 86, 76, 76,
            76, 77, 78, 79, 79, 79, 79, 80, 72, 72, 72, 72, 72, 72, 67, 63, 63, 63, 63, 63, 57, 57, 57, 57, 57, 57, 57,
            34, 34, 34, 34, 34, 33, 28
        ],
        "TacklesForLossAllowed": [
            48, 47, 50, 48, 85, 85, 85, 85, 84, 84, 84, 85, 85, 85, 85, 27, 27, 27, 27, 27, 39, 34, 34, 34, 33, 33, 29,
            29, 28, 28, 27, 42, 42, 42, 43, 43, 43, 46, 45, 45, 45, 45, 45, 44, 44, 44, 44, 43, 43, 43, 32, 32, 32, 32,
            31, 31, 55
        ],
        "TeamPassingEfficiency": [
            54, 54, 54, 53, 123, 123, 123, 123, 123, 123, 123, 123, 123, 123, 123, 117, 117, 117, 117, 117, 117, 119,
            119, 119, 120, 120, 110, 110, 111, 110, 110, 95, 95, 95, 96, 96, 96, 92, 88, 88, 87, 87, 87, 87, 87, 87, 87,
            87, 87, 87, 61, 61, 61, 61, 60, 60, 48
        ],
        "TeamPassingEfficiencyDefense": [
            43, 43, 43, 41, 79, 79, 79, 79, 79, 79, 79, 79, 79, 79, 79, 44, 44, 44, 44, 61, 61, 62, 62, 62, 61, 59, 66,
            66, 65, 66, 67, 66, 66, 66, 66, 66, 66, 67, 62, 61, 61, 63, 63, 60, 60, 60, 60, 60, 60, 60, 48, 48, 48, 48,
            47, 47, 35
        ],
        "TeamSacks": [
            48, 49, 49, 49, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 12, 12, 13, 13, 26, 26, 22, 22, 22, 22, 23, 47,
            47, 48, 48, 46, 38, 38, 38, 38, 38, 38, 57, 60, 59, 59, 59, 59, 52, 52, 52, 52, 52, 52, 52, 24, 24, 24, 26,
            27, 27, 27
        ],
        "TeamTacklesForLoss": [
            109, 110, 110, 111, 73, 73, 73, 73, 73, 73, 73, 72, 72, 72, 72, 57, 57, 57, 57, 66, 65, 61, 61, 61, 62, 64,
            94, 94, 94, 94, 95, 97, 97, 97, 97, 97, 97, 108, 109, 109, 109, 109, 109, 110, 110, 110, 110, 110, 111, 111,
            63, 63, 63, 64, 65, 65, 61
        ],
        "ThirdDownConversionPct": [
            132, 132, 133, 133, 135, 135, 135, 135, 135, 135, 135, 135, 135, 135, 135, 133, 133, 133, 133, 133, 137,
            137, 137, 137, 137, 137, 131, 131, 131, 131, 132, 126, 126, 126, 126, 126, 126, 118, 119, 119, 120, 120,
            119, 119, 119, 119, 119, 119, 119, 119, 115, 115, 115, 114, 113, 113, 121
        ],
        "ThirdDownConversionPctDefense": [
            56, 57, 57, 58, 66, 66, 66, 66, 66, 66, 66, 65, 65, 65, 65, 63, 63, 63, 63, 63, 78, 70, 70, 70, 70, 70, 104,
            104, 104, 104, 104, 97, 97, 97, 98, 98, 99, 95, 94, 94, 94, 93, 92, 93, 93, 93, 93, 93, 93, 94, 68, 68, 68,
            68, 67, 67, 48
        ],
        "TimeOfPossession": [
            93, 93, 93, 94, 87, 87, 87, 87, 86, 86, 86, 85, 85, 85, 85, 116, 116, 116, 116, 123, 123, 123, 123, 124,
            123, 123, 128, 128, 128, 129, 129, 122, 122, 122, 122, 122, 123, 124, 125, 126, 126, 126, 126, 130, 130,
            130, 130, 130, 130, 130, 119, 119, 119, 119, 119, 119, 121
        ],
        "TotalDefense": [
            89, 89, 89, 90, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 86, 86, 86, 86, 115, 116, 116, 116, 116, 116,
            116, 124, 124, 125, 125, 123, 116, 116, 116, 117, 117, 117, 115, 115, 114, 114, 115, 115, 114, 114, 114,
            114, 114, 113, 113, 96, 96, 96, 96, 95, 94, 95
        ],
        "TotalOffense": [
            95, 96, 96, 98, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 97, 102, 102, 102, 102, 102, 102, 100, 100, 100,
            100, 102, 98, 98, 98, 96, 96, 90, 90, 90, 91, 91, 90, 87, 87, 87, 87, 86, 86, 79, 79, 79, 79, 79, 79, 79,
            62, 62, 62, 62, 61, 61, 46
        ],
        "TurnoverMargin": [
            5, 5, 5, 5, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 30, 30, 30, 30, 22, 21, 13, 13, 13, 13, 13, 4, 4, 4, 4, 4, 4,
            4, 4, 4, 4, 4, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 7
        ],
        "TurnoversGained": [
            3, 3, 4, 5, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 17, 17, 17, 17, 4, 4, 9, 9, 9, 9, 10, 3, 3, 3, 3, 3, 6, 6,
            6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 12
        ],
        "TurnoversLost": [
            47, 47, 47, 46, 21, 21, 21, 21, 20, 20, 20, 19, 19, 19, 19, 47, 47, 47, 47, 47, 47, 32, 32, 32, 32, 32, 23,
            23, 22, 22, 21, 15, 15, 15, 14, 14, 14, 23, 17, 17, 17, 16, 16, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 5, 4, 4, 18
        ],
        "WinningPercentage": [
            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 24, 24, 24, 24, 66, 65, 53, 53, 53, 54, 55, 73, 73, 72, 72, 73,
            63, 63, 63, 62, 62, 62, 77, 82, 82, 82, 81, 81, 68, 68, 68, 68, 69, 69, 69, 54, 54, 54, 55, 55, 55, 41
        ]
    ]
}
#endif
