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

    @ObservationIgnored private let fetchMetadata: () async throws -> RankingsMetadata

    init(fetchMetadata: @escaping () async throws -> RankingsMetadata = RankingsAPI.metadata) {
        #if DEBUG
        // Screenshots show the frozen rankings' time rather than calling the API.
        self.fetchMetadata = ScreenshotMode.isEnabled ? ScreenshotFixtures.metadata : fetchMetadata
        #else
        self.fetchMetadata = fetchMetadata
        #endif
    }

    func load() async {
        guard let scrapedAt = try? await fetchMetadata().scrapedAt, !Task.isCancelled else { return }
        date = scrapedAt
    }
}
