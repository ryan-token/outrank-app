//
//  TeamRankingsModel.swift
//  Outrank
//
//  Created by Ryan Token on 10/2/21.
//

import Foundation
import OSLog

/// Loads one team's ranking in every stat and keeps them sorted for display.
///
/// Sorting happens here, when the rankings or the sort order change, rather than in a
/// view's `body`, which SwiftUI can evaluate far more often than either changes.
@Observable
final class TeamRankingsModel {
    static let teamKey = "CurrentTeam"
    static let defaultTeam = "Air Force"

    /// The team being shown. Persisted so the app reopens on the same team.
    var team: String {
        didSet {
            guard team != oldValue else { return }
            defaults.set(team, forKey: Self.teamKey)
            // Drop the previous team's rankings so they never show under the new name.
            snapshot = nil
            loadedAt = nil
            loadFailed = false
            resort()
        }
    }

    var sortMethod: SortMethod = .byStatAlphabetically {
        didSet { resort() }
    }

    /// Every stat with the team's ranking in it, in `sortMethod` order. Empty until the
    /// team's rankings load.
    private(set) var sortedRankings: [RankingEntry] = []
    private(set) var loadFailed = false

    /// Changes whenever `sortedRankings` does. Views animate on this rather than on the
    /// rankings themselves, which would be compared element by element on every update.
    private(set) var revision = 0

    /// When the rankings on screen were scraped; `nil` until the team's rankings load.
    var lastUpdated: Date? {
        snapshot?.scrapedAt
    }

    /// Whether the team is still waiting for its first rankings, as opposed to loaded or
    /// failed. Refreshing already-loaded rankings doesn't count.
    var isAwaitingFirstLoad: Bool {
        snapshot == nil && !loadFailed
    }

    private var snapshot: RankingsSnapshot?

    /// When `snapshot` arrived, for deciding whether it is still current.
    @ObservationIgnored private var loadedAt: Date?

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let fetch: (String) async throws -> RankingsSnapshot
    @ObservationIgnored private let now: () -> Date

    private static let logger = Logger(category: "TeamRankingsModel")

    init(
        defaults: UserDefaults = .standard,
        fetch: @escaping (String) async throws -> RankingsSnapshot = RankingsAPI.teamRankings(for:),
        now: @escaping () -> Date = Date.init
    ) {
        self.defaults = defaults
        self.now = now
        #if DEBUG
        // Screenshots load frozen rankings rather than calling the API.
        self.fetch = ScreenshotMode.isEnabled ? ScreenshotFixtures.teamRankings(for:) : fetch
        #else
        self.fetch = fetch
        #endif
        team = defaults.string(forKey: Self.teamKey) ?? Self.defaultTeam

        #if DEBUG
        if let sortMethod = ScreenshotMode.sortMethod {
            self.sortMethod = sortMethod
        }
        #endif
    }

    /// The team's ranking in a stat, or `nil` when it has none.
    func ranking(forStat stat: String) -> Int? {
        snapshot?.ranks[stat]
    }

    /// Fetches the current team's rankings.
    /// - Returns: Whether the rankings loaded and are now on screen.
    @discardableResult
    func load() async -> Bool {
        let requestedTeam = team

        do {
            let snapshot = try await fetch(requestedTeam)
            // The team may have changed while this request was in flight; its own load
            // will supply the rankings.
            guard !Task.isCancelled, requestedTeam == team else { return false }
            self.snapshot = snapshot
            loadedAt = now()
            loadFailed = false
            resort()
            return true
        } catch {
            guard !Task.isCancelled, requestedTeam == team else { return false }
            Self.logger.error(
                "Failed to load rankings for \(requestedTeam, privacy: .public): \(String(describing: error))"
            )
            loadFailed = true
            return false
        }
    }

    /// Fetches the current team's rankings unless the ones on screen are still current,
    /// so returning to the tab or the app doesn't refetch what it just loaded.
    /// - Returns: Whether new rankings loaded and are now on screen.
    @discardableResult
    func loadIfStale() async -> Bool {
        if let loadedAt, !loadFailed, now().timeIntervalSince(loadedAt) < RankingsSnapshot.maxAge {
            return false
        }
        return await load()
    }

    private func resort() {
        guard let snapshot else {
            sortedRankings = []
            revision += 1
            return
        }

        let entries = AllStats.including(snapshot.ranks.keys).map { stat in
            RankingEntry(id: stat, title: Conversions.humanReadableStat(for: stat), ranking: snapshot.ranks[stat])
        }
        sortedRankings = sortMethod.sorted(entries)
        revision += 1
    }
}
