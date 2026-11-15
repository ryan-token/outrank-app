//
//  RankingsAPI.swift
//  Outrank
//
//  Created by Ryan Token on 10/2/21.
//

import Foundation

/// The rankings backend's v2 API. Shared by the app and the widget extension.
nonisolated enum RankingsAPI {
    enum RankingsAPIError: Error, Equatable {
        case badResponse(statusCode: Int)
    }

    /// One request the API answers.
    enum Endpoint: Equatable, Sendable {
        /// One team's latest ranking in every stat.
        case team(String)

        /// Every team's latest ranking in one stat.
        case stat(String)

        /// One team's ranking in every stat on each day of a season. A `nil` season asks
        /// for the team's most recent one.
        case teamHistory(team: String, season: String?)

        /// What the backend holds: which seasons, and when it last scraped.
        case metadata

        var url: URL {
            let (path, queryItems) = switch self {
            case .team(let team):
                ("team", [URLQueryItem(name: "team", value: team)])
            case .stat(let stat):
                ("stat", [URLQueryItem(name: "stat", value: stat)])
            case .teamHistory(let team, let season):
                (
                    "team/history",
                    [URLQueryItem(name: "team", value: team)]
                        + (season.map { [URLQueryItem(name: "season", value: $0)] } ?? [])
                )
            case .metadata:
                ("meta", [])
            }

            let url = RankingsAPI.baseURL.appending(path: path)
            // `appending(queryItems:)` percent-encodes reserved characters such as the
            // ampersand in "Texas A&M", which would otherwise split the query.
            return queryItems.isEmpty ? url : url.appending(queryItems: queryItems)
        }
    }

    private static let baseURL: URL = {
        // A fixed literal, so a failure here is a typo caught the first time the app runs.
        guard let url = URL(string: "https://api.outrankapp.com/v2") else {
            preconditionFailure("Malformed rankings API URL.")
        }
        return url
    }()

    static func teamRankings(for team: String) async throws -> RankingsSnapshot {
        try await fetch(.team(team))
    }

    static func statRankings(for stat: String) async throws -> RankingsSnapshot {
        try await fetch(.stat(stat))
    }

    static func teamHistory(for team: String, season: String?) async throws -> TeamHistory {
        try await fetch(.teamHistory(team: team, season: season))
    }

    static func metadata() async throws -> RankingsMetadata {
        try await fetch(.metadata)
    }

    /// Decodes a response body the way every endpoint needs it decoded.
    static func decode<Response: Decodable>(_ type: Response.Type = Response.self, from data: Data) throws -> Response {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { try decodeTimestamp(from: $0) }
        return try decoder.decode(type, from: data)
    }

    // `@concurrent` so decoding runs off the caller's actor, not on the main thread. A
    // season of history is every stat on every day, which is the largest payload here.
    @concurrent
    private static func fetch<Response: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> Response {
        let (data, response) = try await URLSession.shared.data(from: endpoint.url)

        if let httpResponse = response as? HTTPURLResponse, !(200..<300).contains(httpResponse.statusCode) {
            throw RankingsAPIError.badResponse(statusCode: httpResponse.statusCode)
        }

        return try decode(from: data)
    }

    /// The backend writes timestamps with milliseconds, which `JSONDecoder`'s own
    /// `.iso8601` strategy rejects. Whole seconds are accepted too, so a change in the
    /// backend's precision can't break decoding.
    private static func decodeTimestamp(from decoder: any Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        if let date = try? Date(string, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)) {
            return date
        }
        if let date = try? Date(string, strategy: .iso8601) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Not an ISO 8601 timestamp: \(string)")
    }
}
