//
//  RankingsAPITests.swift
//  OutrankTests
//

import Foundation
import Testing
@testable import Outrank

struct RankingsAPITests {
    /// 2026-11-14 00:18:38 UTC.
    private static let scrapedAt = Date(timeIntervalSince1970: 1_794_615_518)

    @Test func decodesATeamsSnapshot() throws {
        let json = Data(#"""
            {"date":"2026-11-14","scrapedAt":"2026-11-14T00:18:38.816Z","season":"2026","throughGames":"2026-11-12",
             "team":"Tulsa","ranks":{"ScoringOffense":34,"TotalDefense":101}}
            """#.utf8)

        let snapshot: RankingsSnapshot = try RankingsAPI.decode(from: json)

        #expect(snapshot.ranks == ["ScoringOffense": 34, "TotalDefense": 101])
    }

    @Test func decodesMetadata() throws {
        let json = Data(#"""
            {"version":"9bfe9fc","date":"2026-11-14","scrapedAt":"2026-11-14T00:18:38.816Z","season":"2026",
             "throughGames":"2026-11-12","seasons":["2025","2026"]}
            """#.utf8)

        let metadata: RankingsMetadata = try RankingsAPI.decode(from: json)

        #expect(metadata.seasons == ["2025", "2026"])
        // The backend's timestamps carry milliseconds, which the decoder must keep.
        let scrapedAt = try #require(metadata.scrapedAt)
        #expect(abs(scrapedAt.timeIntervalSince(Self.scrapedAt) - 0.816) < 0.001)
    }

    @Test(arguments: ["2026-11-14T00:18:38Z", "2026-11-14T00:18:38.000Z"])
    func timestampsDecodeWithOrWithoutFractionalSeconds(timestamp: String) throws {
        let json = Data(#"{"scrapedAt":"\#(timestamp)","seasons":[]}"#.utf8)

        let metadata: RankingsMetadata = try RankingsAPI.decode(from: json)

        #expect(metadata.scrapedAt == Self.scrapedAt)
    }

    @Test func timestampThatIsNotISO8601IsRejected() {
        let json = Data(#"{"scrapedAt":"yesterday","seasons":[]}"#.utf8)

        #expect(throws: DecodingError.self) {
            let _: RankingsMetadata = try RankingsAPI.decode(from: json)
        }
    }

    @Test func decodesAHistoryWithDaysTheTeamWasNotRanked() throws {
        let json = Data(#"""
            {"team":"Tulsa","season":"2025","dates":["2025-09-06","2025-09-07"],
             "ranks":{"ScoringOffense":[null,45],"TotalDefense":[22,21]}}
            """#.utf8)

        let history: TeamHistory = try RankingsAPI.decode(from: json)

        #expect(history == TeamHistory(
            season: "2025",
            dates: ["2025-09-06", "2025-09-07"],
            ranks: ["ScoringOffense": [nil, 45], "TotalDefense": [22, 21]]
        ))
    }

    // Team names reach the query as they are, so one with an ampersand must not split it.
    @Test(arguments: [
        (RankingsAPI.Endpoint.team("Texas A&M"), "/v2/team", ["team": "Texas A&M"]),
        (.stat("ScoringOffense"), "/v2/stat", ["stat": "ScoringOffense"]),
        (
            .teamHistory(team: "Miami (FL)", season: "2025"),
            "/v2/team/history",
            ["team": "Miami (FL)", "season": "2025"]
        ),
        (.teamHistory(team: "Tulsa", season: nil), "/v2/team/history", ["team": "Tulsa"]),
        (.metadata, "/v2/meta", [:])
    ])
    func endpointURLs(endpoint: RankingsAPI.Endpoint, path: String, query: [String: String]) throws {
        let components = try #require(URLComponents(url: endpoint.url, resolvingAgainstBaseURL: false))

        #expect(components.path == path)
        let queryItems = (components.queryItems ?? []).map { [$0.name: $0.value] }
        #expect(queryItems.count == query.count)
        for (name, value) in query {
            #expect(queryItems.contains([name: value]))
        }
    }
}
