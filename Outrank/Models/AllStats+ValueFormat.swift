//
//  AllStats+ValueFormat.swift
//  Outrank
//

import Foundation

nonisolated extension AllStats {
    /// How to write out a stat's value. A stat the backend added after this version shipped
    /// is `unlisted`, and still shows its number.
    static func valueFormat(for stat: String) -> StatValueFormat {
        valueFormats[stat] ?? .unlisted
    }

    /// A team's value in a stat, ready to show, or `nil` when it has none.
    static func formattedValue(_ value: Double?, for stat: String) -> String? {
        value.map(valueFormat(for: stat).string(for:))
    }

    /// The decimal places are the ones ncaa.com prints each stat with, which is why Scoring
    /// Offense has one and Scoring Defense two.
    private static let valueFormats: [String: StatValueFormat] = [
        "BlockedKicks": .count,
        "BlockedKicksAllowed": .count,
        "BlockedPunts": .count,
        "BlockedPuntsAllowed": .count,
        "CompletionPercentage": .percent,
        "DefensiveTDs": .count,
        "FewestPenalties": .count,
        "FewestPenaltiesPerGame": .decimal(places: 2),
        "FewestPenaltyYards": .count,
        "FewestPenaltyYardsPerGame": .decimal(places: 2),
        "FirstDownsDefense": .count,
        "FirstDownsOffense": .count,
        "FourthDownConversionPct": .percent,
        "FourthDownConversionPctDefense": .percent,
        "FumblesLost": .count,
        "FumblesRecovered": .count,
        "KickoffReturnDefense": .decimal(places: 2),
        "KickoffReturns": .decimal(places: 2),
        "NetPunting": .decimal(places: 2),
        "PassesHadIntercepted": .count,
        "PassesIntercepted": .count,
        "PassingOffense": .decimal(places: 1),
        "PassingYardsAllowed": .decimal(places: 1),
        "PassingYardsPerCompletion": .decimal(places: 2),
        "PuntReturnDefense": .decimal(places: 2),
        "PuntReturns": .decimal(places: 2),
        "RedZoneDefense": .percent,
        "RedZoneOffense": .percent,
        "RushingDefense": .decimal(places: 1),
        "RushingOffense": .decimal(places: 1),
        "SacksAllowed": .decimal(places: 2),
        "ScoringDefense": .decimal(places: 2),
        "ScoringOffense": .decimal(places: 1),
        "TacklesForLossAllowed": .decimal(places: 2),
        "TeamPassingEfficiency": .rating(places: 2),
        "TeamPassingEfficiencyDefense": .rating(places: 2),
        "TeamSacks": .decimal(places: 2),
        "TeamTacklesForLoss": .decimal(places: 1),
        "ThirdDownConversionPct": .percent,
        "ThirdDownConversionPctDefense": .percent,
        "TimeOfPossession": .minutes,
        "TotalDefense": .decimal(places: 1),
        "TotalOffense": .decimal(places: 1),
        "TurnoverMargin": .decimal(places: 2),
        "TurnoversGained": .count,
        "TurnoversLost": .count,
        "WinningPercentage": .percent
    ]
}
