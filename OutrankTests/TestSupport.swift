//
//  TestSupport.swift
//  OutrankTests
//

import Foundation
@testable import Outrank

/// A failure for stubbed fetches to throw.
struct StubError: Error {}

extension Bundle {
    /// The test bundle, which holds the tests' own resources. `Bundle.main` is the app.
    static let tests = Bundle(for: TestBundleToken.self)
}

private final class TestBundleToken {}

/// Defaults in their own suite, so tests neither read nor clobber the app's settings.
func makeIsolatedDefaults() -> UserDefaults {
    let suiteName = "OutrankTests.\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
        preconditionFailure("Could not create a UserDefaults suite for testing.")
    }
    return defaults
}

/// Lets a stubbed fetch reach the model it was injected into, to simulate the user
/// changing something while a request is in flight.
final class ModelReference<Model: AnyObject> {
    weak var model: Model?
}

extension RankingsSnapshot {
    static func stub(_ ranks: [String: Int] = [:], values: [String: Double] = [:]) -> Self {
        RankingsSnapshot(ranks: ranks, values: values)
    }
}
