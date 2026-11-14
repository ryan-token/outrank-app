//
//  HistoryModel.swift
//  Outrank
//

import Foundation
import OSLog

/// Loads one team's rankings across a season and prepares the chosen stat for the chart.
///
/// A season arrives with every stat in it, so choosing another stat only rebuilds the
/// series from what is already loaded.
@Observable
final class HistoryModel {
    static let teamKey = "HistoryTeam"
    static let statKey = "HistoryStat"
    static let defaultStat = "ScoringOffense"

    /// The team being shown. Persisted so the screen reopens on the same team.
    var team: String {
        didSet {
            guard team != oldValue else { return }
            defaults.set(team, forKey: Self.teamKey)
            dropHistory()
        }
    }

    /// The stat being charted. Persisted alongside the team.
    var stat: String {
        didSet {
            guard stat != oldValue else { return }
            defaults.set(stat, forKey: Self.statKey)
            rebuildSeries()
        }
    }

    /// The season to show, or `nil` to follow the team's most recent one. Set through
    /// `selectedSeason`.
    private(set) var season: String? {
        didSet {
            guard season != oldValue else { return }
            dropHistory()
        }
    }

    /// The season on screen, for a picker to bind to. `nil` only before anything has loaded.
    var selectedSeason: String? {
        get { season ?? history?.season ?? seasons.first }
        // Choosing the newest season goes back to following the latest one, so the
        // screen moves on by itself when a new season starts.
        set { season = newValue == seasons.first ? nil : newValue }
    }

    /// Every season with history, newest first. Empty until the backend has said.
    private(set) var seasons: [String] = []

    /// Every stat that can be charted: the app's catalog, plus any the backend has added
    /// since this version shipped.
    private(set) var stats = AllStats.all

    private(set) var phase = HistoryPhase.loading

    /// The stats whose names, as the picker shows them, match text typed into its search
    /// field. An empty search matches them all.
    func stats(matching searchText: String) -> [String] {
        stats.filter { Conversions.humanReadableStat(for: $0).matchesSearch(searchText) }
    }

    /// The chosen stat across the season on screen. Empty until the season loads.
    private(set) var series = HistorySeries.empty

    /// Where the user is pointing on the chart, as the chart reports it. Only the chart's
    /// selection binding should touch this; everything else reads `selectedPoint`, which
    /// changes once per day crossed rather than on every movement.
    var rawSelectedDate: Date? {
        didSet { resolveSelection() }
    }

    /// The day nearest to where the user is pointing, or `nil` when they aren't.
    private(set) var selectedPoint: HistoryPoint?

    /// The day to spell out beside the chart: the one being pointed at, or else the most
    /// recent day with a ranking.
    var focusedPoint: HistoryPoint? {
        selectedPoint ?? series.latest
    }

    private var history: TeamHistory?

    /// `history`'s days, parsed once so changing the stat doesn't parse them again.
    @ObservationIgnored private var days: [Date] = []

    /// When `history` arrived, for deciding whether it is still current.
    @ObservationIgnored private var loadedAt: Date?

    /// Whether the backend has listed the seasons. Until it has, `seasons` holds only the
    /// ones that have been loaded.
    @ObservationIgnored private var hasLoadedSeasons = false

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let timeZone: TimeZone
    @ObservationIgnored private let fetchHistory: (String, String?) async throws -> TeamHistory
    @ObservationIgnored private let fetchMetadata: () async throws -> RankingsMetadata
    @ObservationIgnored private let now: () -> Date

    private static let logger = Logger(category: "HistoryModel")

    init(
        defaults: UserDefaults = .standard,
        timeZone: TimeZone = .autoupdatingCurrent,
        fetchHistory: @escaping (String, String?) async throws -> TeamHistory = RankingsAPI.teamHistory(for:season:),
        fetchMetadata: @escaping () async throws -> RankingsMetadata = RankingsAPI.metadata,
        now: @escaping () -> Date = Date.init
    ) {
        self.defaults = defaults
        self.timeZone = timeZone
        self.now = now
        #if DEBUG
        // Screenshots load a frozen season rather than calling the API.
        self.fetchHistory = ScreenshotMode.isEnabled ? ScreenshotFixtures.teamHistory(for:season:) : fetchHistory
        self.fetchMetadata = ScreenshotMode.isEnabled ? ScreenshotFixtures.metadata : fetchMetadata
        #else
        self.fetchHistory = fetchHistory
        self.fetchMetadata = fetchMetadata
        #endif

        // A first visit starts on the team the Rankings tab is showing.
        team = defaults.string(forKey: Self.teamKey)
            ?? defaults.string(forKey: TeamRankingsModel.teamKey)
            ?? TeamRankingsModel.defaultTeam
        // The saved stat is kept even when this version's catalog doesn't list it, since
        // the backend may have added it after this version shipped. Listing it gives the
        // stat picker something to show as selected until a season says what there is.
        let stat = defaults.string(forKey: Self.statKey) ?? Self.defaultStat
        self.stat = stat
        stats = AllStats.including([stat])
    }

    /// Fetches the team's history for the chosen season, and the list of seasons if the
    /// backend hasn't supplied it yet.
    func load() async {
        async let seasonsLoad: Void = loadSeasonsIfNeeded()
        async let historyLoad: Void = loadHistory()
        _ = await (seasonsLoad, historyLoad)
    }

    /// Loads unless the season on screen is still current, so returning to the tab or the
    /// app doesn't refetch what it just loaded.
    func loadIfStale() async {
        if history != nil, let loadedAt, now().timeIntervalSince(loadedAt) < RankingsSnapshot.maxAge {
            return
        }
        await load()
    }

    private func loadHistory() async {
        let requestedTeam = team
        let requestedSeason = season
        // A retry after a failed load shows that it is under way. A refresh has a season
        // to keep on screen instead.
        if history == nil {
            phase = .loading
        }

        do {
            let history = try await fetchHistory(requestedTeam, requestedSeason)
            // The team or season may have changed while this request was in flight; its
            // own load will supply the history.
            guard !Task.isCancelled, requestedTeam == team, requestedSeason == season else { return }
            self.history = history
            days = HistorySeries.days(from: history.dates, season: history.season, timeZone: timeZone)
            loadedAt = now()
            phase = .loaded
            // The list can be missing this season: the backend may not have supplied the
            // list yet, or a new season may have started since it did.
            addSeasons([history.season])
            stats = AllStats.including(history.ranks.keys)
            if stats.contains(stat) {
                rebuildSeries()
            } else {
                // Neither the app nor the backend has the saved stat any more. Setting
                // the stat charts the new one.
                stat = Self.defaultStat
            }
        } catch {
            guard !Task.isCancelled, requestedTeam == team, requestedSeason == season else { return }
            Self.logger.error(
                "Failed to load history for \(requestedTeam, privacy: .public): \(String(describing: error))"
            )
            // A failed refresh keeps the season already on screen.
            if history == nil {
                phase = .failed
            }
        }
    }

    private func loadSeasonsIfNeeded() async {
        guard !hasLoadedSeasons else { return }

        do {
            let metadata = try await fetchMetadata()
            addSeasons(metadata.seasons)
            hasLoadedSeasons = true
        } catch {
            guard !Task.isCancelled else { return }
            // The season picker makes do with the season on screen until a later load.
            Self.logger.error("Failed to load seasons: \(String(describing: error))")
        }
    }

    /// Adds seasons the backend has reported to the list, which only ever grows: a season
    /// loaded a moment ago can be newer than any in a list fetched alongside it.
    private func addSeasons(_ reported: [String]) {
        let merged = Set(seasons).union(reported).sorted(by: >)
        if merged != seasons {
            seasons = merged
        }
    }

    /// Clears the season on screen when the team or season changes, so one team's history
    /// never shows under another's name while the new one loads.
    private func dropHistory() {
        history = nil
        days = []
        loadedAt = nil
        phase = .loading
        rebuildSeries()
    }

    private func rebuildSeries() {
        if let history {
            series = HistorySeries(
                title: Conversions.humanReadableStat(for: stat),
                days: days,
                rankings: history.ranks[stat] ?? []
            )
        } else {
            series = .empty
        }
        // The selection follows the data: a point from the old series can't stay selected.
        resolveSelection()
    }

    private func resolveSelection() {
        selectedPoint = rawSelectedDate.flatMap { series.point(nearest: $0) }
    }
}
