//
//  FBSTeam.swift
//  Outrank
//
//  Created by Ryan Token on 9/4/26.
//

import Foundation

/// One FBS program.
nonisolated struct FBSTeam: Identifiable, Hashable, Sendable {
    /// The name ncaa.com uses, which is also what the rankings API knows the team by.
    let name: String

    var id: String { name }
}
