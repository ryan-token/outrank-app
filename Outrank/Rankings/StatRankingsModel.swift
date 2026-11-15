//
//  StatRankingsModel.swift
//  Outrank
//
//  Created by Ryan Token on 10/4/21.
//

import Foundation
import OSLog

/// Loads every team's ranking in one stat, ordered best to worst.
@Observable
final class StatRankingsModel {
    private(set) var entries: [RankingEntry] = []
    private(set) var loadFailed = false

    /// Changes whenever `entries` does, giving views a cheap value to animate on.
    private(set) var revision = 0

    /// When `entries` arrived, for deciding whether they are still current.
    @ObservationIgnored private var loadedAt: Date?

    @ObservationIgnored private let fetch: (String) async throws -> RankingsSnapshot
    @ObservationIgnored private let now: () -> Date

    private static let logger = Logger(category: "StatRankingsModel")

    init(
        fetch: @escaping (String) async throws -> RankingsSnapshot = RankingsAPI.statRankings(for:),
        now: @escaping () -> Date = Date.init
    ) {
        self.now = now
        #if DEBUG
        // Screenshots load frozen rankings rather than calling the API.
        self.fetch = ScreenshotMode.isEnabled ? ScreenshotFixtures.statRankings(for:) : fetch
        #else
        self.fetch = fetch
        #endif
    }

    func load(stat: String) async {
        do {
            let snapshot = try await fetch(stat)
            guard !Task.isCancelled else { return }
            // The API leaves out teams with no ranking in the stat. They still get a row,
            // after the ranked ones, so every team can be found in the list.
            let teams = Set(AllTeams.all.map(\.name)).union(snapshot.ranks.keys)
            let unsorted = teams.map { team in
                RankingEntry(id: team, title: team, ranking: snapshot.ranks[team])
            }
            entries = SortMethod.byRankingAscending.sorted(unsorted)
            loadedAt = now()
            loadFailed = false
            revision += 1
        } catch {
            guard !Task.isCancelled else { return }
            Self.logger.error("Failed to load rankings for \(stat, privacy: .public): \(String(describing: error))")
            loadFailed = true
        }
    }

    /// Loads unless the rankings on screen are still current, so returning to the app
    /// doesn't refetch what it just loaded.
    func loadIfStale(stat: String) async {
        if !loadFailed, RankingsSnapshot.isCurrent(loadedAt: loadedAt, now: now()) {
            return
        }
        await load(stat: stat)
    }
}
