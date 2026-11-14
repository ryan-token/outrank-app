//
//  ComparisonModel.swift
//  Outrank
//
//  Created by Ryan Token on 10/2/21.
//

import Foundation
import OSLog

/// Loads two teams' rankings and lines them up stat by stat.
@Observable
final class ComparisonModel {
    static let teamOneKey = "TeamOne"
    static let teamTwoKey = "TeamTwo"

    /// Persisted so the comparison reopens on the same teams. Set through
    /// `subscript(team:)` or `swapTeams()`, which keep each slot's rankings in step.
    private(set) var teamOne: String {
        didSet { defaults.set(teamOne, forKey: Self.teamOneKey) }
    }

    private(set) var teamTwo: String {
        didSet { defaults.set(teamTwo, forKey: Self.teamTwoKey) }
    }

    /// Orders rows by stat name, or by team one's ranking.
    var sortMethod: SortMethod = .byStatAlphabetically {
        didSet { rebuildRows() }
    }

    /// Every stat with both teams' rankings in it, in `sortMethod` order. Empty until one
    /// of the teams' rankings load.
    private(set) var rows: [ComparisonEntry] = []

    /// Changes whenever `rows` does, giving views a cheap value to animate on.
    private(set) var revision = 0

    var loadFailed: Bool {
        teamOneState.loadFailed || teamTwoState.loadFailed
    }

    private var teamOneState = SlotState()
    private var teamTwoState = SlotState()

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let fetch: (String) async throws -> RankingsSnapshot
    @ObservationIgnored private let now: () -> Date

    private static let logger = Logger(category: "ComparisonModel")

    /// What a slot has loaded for its current team.
    private struct SlotState {
        /// `nil` until the team's rankings first load.
        var snapshot: RankingsSnapshot?
        var average: Int?

        /// When `snapshot` arrived, for deciding whether it is still current.
        var loadedAt: Date?
        var loadFailed = false
    }

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
        teamOne = defaults.string(forKey: Self.teamOneKey) ?? "Tulsa"
        teamTwo = defaults.string(forKey: Self.teamTwoKey) ?? "SMU"

        #if DEBUG
        if let sortMethod = ScreenshotMode.sortMethod {
            self.sortMethod = sortMethod
        }
        #endif
    }

    /// The team in a slot. Writable, so a picker can bind straight to `$model[team: slot]`.
    /// Picking a new team drops the slot's old rankings so they never show under its name.
    subscript(team slot: ComparisonSlot) -> String {
        get {
            switch slot {
            case .teamOne: teamOne
            case .teamTwo: teamTwo
            }
        }
        set {
            guard newValue != self[team: slot] else { return }
            switch slot {
            case .teamOne: teamOne = newValue
            case .teamTwo: teamTwo = newValue
            }
            self[state: slot] = SlotState()
            rebuildRows()
        }
    }

    /// The mean of a slot's rankings, or `nil` while it has none.
    func average(for slot: ComparisonSlot) -> Int? {
        self[state: slot].average
    }

    /// Whether a slot's team is still waiting for its first rankings, as opposed to
    /// loaded or failed. Refreshing already-loaded rankings doesn't count.
    func isAwaitingFirstLoad(_ slot: ComparisonSlot) -> Bool {
        let state = self[state: slot]
        return state.snapshot == nil && !state.loadFailed
    }

    /// Exchanges the two teams, carrying their already-loaded rankings across so the
    /// screen updates immediately.
    func swapTeams() {
        (teamOne, teamTwo) = (teamTwo, teamOne)
        (teamOneState, teamTwoState) = (teamTwoState, teamOneState)
        rebuildRows()
    }

    func loadBothTeams() async {
        async let teamOneLoad: Void = load(.teamOne)
        async let teamTwoLoad: Void = load(.teamTwo)
        _ = await (teamOneLoad, teamTwoLoad)
    }

    /// Loads each team whose rankings are missing, failed, or older than
    /// `RankingsSnapshot.maxAge`. Teams still current, such as both teams right after a
    /// swap, aren't fetched again.
    func loadStaleTeams() async {
        async let teamOneLoad: Void = loadIfStale(.teamOne)
        async let teamTwoLoad: Void = loadIfStale(.teamTwo)
        _ = await (teamOneLoad, teamTwoLoad)
    }

    func load(_ slot: ComparisonSlot) async {
        let requestedTeam = self[team: slot]

        do {
            let snapshot = try await fetch(requestedTeam)
            // The slot may hold a different team by now, after a swap or a new pick.
            guard !Task.isCancelled, requestedTeam == self[team: slot] else { return }
            self[state: slot] = SlotState(
                snapshot: snapshot,
                average: RankingStatistics.simpleAverage(of: snapshot.ranks.values),
                loadedAt: now()
            )
            rebuildRows()
        } catch {
            guard !Task.isCancelled, requestedTeam == self[team: slot] else { return }
            Self.logger.error(
                "Failed to load rankings for \(requestedTeam, privacy: .public): \(String(describing: error))"
            )
            self[state: slot].loadFailed = true
        }
    }

    private func loadIfStale(_ slot: ComparisonSlot) async {
        let state = self[state: slot]

        if let loadedAt = state.loadedAt,
           !state.loadFailed,
           now().timeIntervalSince(loadedAt) < RankingsSnapshot.maxAge {
            return
        }
        await load(slot)
    }

    private subscript(state slot: ComparisonSlot) -> SlotState {
        get {
            switch slot {
            case .teamOne: teamOneState
            case .teamTwo: teamTwoState
            }
        }
        set {
            switch slot {
            case .teamOne: teamOneState = newValue
            case .teamTwo: teamTwoState = newValue
            }
        }
    }

    private func rebuildRows() {
        defer { revision += 1 }

        // Nothing to line up until a team has rankings.
        guard teamOneState.snapshot != nil || teamTwoState.snapshot != nil else {
            rows = []
            return
        }

        let teamOneRanks = teamOneState.snapshot?.ranks ?? [:]
        let teamTwoRanks = teamTwoState.snapshot?.ranks ?? [:]

        let teamOneEntries = AllStats.including(Array(teamOneRanks.keys) + teamTwoRanks.keys).map { stat in
            RankingEntry(id: stat, title: Conversions.humanReadableStat(for: stat), ranking: teamOneRanks[stat])
        }

        rows = sortMethod.sorted(teamOneEntries).map { entry in
            ComparisonEntry(
                id: entry.id,
                title: entry.title,
                teamOneRanking: entry.ranking,
                teamTwoRanking: teamTwoRanks[entry.id]
            )
        }
    }
}
