//
//  LastUpdatedModel.swift
//  Outrank
//

import Foundation

/// Loads when the backend last refreshed the rankings, for Settings to show.
@Observable
final class LastUpdatedModel {
    /// `nil` until it loads. A failed load leaves the last known time in place.
    private(set) var date: Date?

    /// When `date` arrived, for deciding whether it is still current.
    @ObservationIgnored private var loadedAt: Date?

    @ObservationIgnored private let fetchMetadata: () async throws -> RankingsMetadata
    @ObservationIgnored private let now: () -> Date

    init(
        fetchMetadata: @escaping () async throws -> RankingsMetadata = RankingsAPI.metadata,
        now: @escaping () -> Date = Date.init
    ) {
        self.now = now
        #if DEBUG
        // Screenshots show the frozen rankings' time rather than calling the API.
        self.fetchMetadata = ScreenshotMode.isEnabled ? ScreenshotFixtures.metadata : fetchMetadata
        #else
        self.fetchMetadata = fetchMetadata
        #endif
    }

    /// Loads unless the time on screen is still current, so returning to Settings doesn't
    /// refetch what it just loaded.
    func loadIfStale() async {
        if RankingsSnapshot.isCurrent(loadedAt: loadedAt, now: now()) {
            return
        }
        guard let scrapedAt = try? await fetchMetadata().scrapedAt, !Task.isCancelled else { return }
        date = scrapedAt
        loadedAt = now()
    }
}
