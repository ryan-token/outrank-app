//
//  SubscriptionTier.swift
//  Outrank
//
//  Created by Ryan Token on 10/17/21.
//

import Foundation

/// Subscription levels in ascending order, for picking the highest one a user holds.
/// Every level unlocks the same features; they differ only in how much they support
/// development.
nonisolated enum SubscriptionTier: Int, CaseIterable, Comparable {
    case none = 0
    case small = 1
    case medium = 2
    case large = 3
    case giant = 4

    /// Every subscription's App Store product identifier, lowest level first.
    static let productIDs = allCases.compactMap(\.productID)

    /// The level a product belongs to, or `.none` for anything that isn't a subscription.
    init(productID: String) {
        self = Self.allCases.first { $0.productID == productID } ?? .none
    }

    var productID: String? {
        switch self {
        case .none: nil
        case .small: "subscription.small"
        case .medium: "subscription.medium"
        case .large: "subscription.large"
        case .giant: "subscription.giant"
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
