//
//  TeamRankingsProvider.swift
//  TopFourWidgetExtension
//
//  Created by Ryan Token on 9/4/26.
//

import OSLog
import WidgetKit

/// Shared by the top-four and bottom-four widgets; they differ only in how they sort.
nonisolated struct TeamRankingsProvider: TimelineProvider {
    private static let logger = Logger(category: "TeamRankingsProvider")

    func placeholder(in context: Context) -> TeamRankingsEntry {
        TeamRankingsEntry(date: .now, team: Self.selectedTeam, rankings: Self.sampleRankings)
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (TeamRankingsEntry) -> Void) {
        // A snapshot has to arrive at once, so it never waits on the network. The gallery
        // shows sample data; anywhere else it shows the last rankings fetched, when there
        // are any, so the widget doesn't flash a made-up team's numbers.
        let team = Self.selectedTeam
        let cached = Self.cachedRankings(for: team)
        let rankings = context.isPreview || cached.isEmpty ? Self.sampleRankings : cached
        completion(TeamRankingsEntry(date: .now, team: team, rankings: rankings))
    }

    // TimelineProvider only offers the completion-handler form, so bridge to async here.
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<TeamRankingsEntry>) -> Void) {
        Task {
            completion(await loadTimeline())
        }
    }

    private func loadTimeline() async -> Timeline<TeamRankingsEntry> {
        let team = Self.selectedTeam

        do {
            let snapshot = try await RankingsAPI.teamRankings(for: team)
            Self.cacheRankings(snapshot.ranks, for: team)
            let entry = TeamRankingsEntry(date: .now, team: team, rankings: snapshot.ranks)
            return Timeline(entries: [entry], policy: .after(Self.nextUpdateDate()))
        } catch {
            Self.logger.error("Failed to fetch rankings for \(team, privacy: .public): \(String(describing: error))")
            // Keep showing the last good rankings through a brief outage, and try again soon.
            let entry = TeamRankingsEntry(date: .now, team: team, rankings: Self.cachedRankings(for: team))
            return Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(3600)))
        }
    }

    // The widget extension's own defaults: the app never reads this cache. The rankings
    // key is not the one version 1 used, whose cache stored a placeholder number for
    // stats the team wasn't ranked in.
    private static let cachedTeamKey = "CachedTeam"
    private static let cachedRankingsKey = "CachedRanks"

    private static func cacheRankings(_ rankings: [String: Int], for team: String) {
        UserDefaults.standard.set(team, forKey: cachedTeamKey)
        UserDefaults.standard.set(rankings, forKey: cachedRankingsKey)
    }

    /// The last rankings fetched for `team`, or none if the widget has since switched teams.
    private static func cachedRankings(for team: String) -> [String: Int] {
        guard UserDefaults.standard.string(forKey: cachedTeamKey) == team else { return [:] }
        return UserDefaults.standard.dictionary(forKey: cachedRankingsKey) as? [String: Int] ?? [:]
    }

    private static var selectedTeam: String {
        AppGroup.defaults?.string(forKey: AppGroup.widgetTeamKey) ?? AppGroup.defaultWidgetTeam
    }

    /// Enough spread that both the top-four and bottom-four widgets look right in the gallery.
    private static let sampleRankings: [String: Int] = [
        "ScoringOffense": 3,
        "TotalOffense": 7,
        "RushingOffense": 11,
        "TurnoverMargin": 14,
        "PassingYardsAllowed": 121,
        "SacksAllowed": 124,
        "FewestPenalties": 128,
        "RedZoneDefense": 131
    ]

    /// The scraper refreshes the rankings at 9:00 AM and 1:00 PM Central, so ask again
    /// half an hour after whichever run is next. A fixed time zone keeps every user's
    /// refresh after the scraper's, wherever they are.
    private static func nextUpdateDate() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Chicago") ?? .current

        let nextUpdates = [9, 13].compactMap { hour in
            calendar.nextDate(
                after: .now,
                matching: DateComponents(hour: hour, minute: 30, second: 0),
                matchingPolicy: .nextTime
            )
        }
        return nextUpdates.min() ?? .now.addingTimeInterval(3600)
    }
}
