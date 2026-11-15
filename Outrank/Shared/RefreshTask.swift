//
//  RefreshTask.swift
//  Outrank
//

import SwiftUI

/// Runs an action when the view appears, when `id` changes, and each time the app returns
/// to the foreground, where it may have sat for days. The action decides whether what is
/// on screen is stale enough to load again.
private struct RefreshTask<ID: Hashable>: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    let id: ID
    let action: @MainActor () async -> Void

    func body(content: Content) -> some View {
        content.task(id: Key(id: id, isActive: scenePhase == .active)) {
            guard scenePhase == .active else { return }
            await action()
        }
    }

    private struct Key: Hashable {
        let id: ID
        let isActive: Bool
    }
}

extension View {
    /// Runs `action` when the view appears, when `id` changes, and each time the app
    /// returns to the foreground. SwiftUI owns the task and cancels it like any other.
    func refreshTask<ID: Hashable>(id: ID = 0, action: @escaping @MainActor () async -> Void) -> some View {
        modifier(RefreshTask(id: id, action: action))
    }
}
