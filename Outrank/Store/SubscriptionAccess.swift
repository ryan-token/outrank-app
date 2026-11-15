//
//  SubscriptionAccess.swift
//  Outrank
//

import Foundation

/// Whether the user holds a subscription, which unlocks subscriber features.
nonisolated enum SubscriptionAccess: Equatable, Sendable {
    /// The first entitlement check hasn't finished. Brief, and only at launch.
    case unknown
    case subscribed
    case notSubscribed
}
