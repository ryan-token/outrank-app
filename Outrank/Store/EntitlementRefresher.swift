//
//  EntitlementRefresher.swift
//  Outrank
//

import SwiftUI

/// Rechecks what the user has unlocked each time the app comes to the foreground.
///
/// StoreKit reports most changes as they happen, but a subscription can also lapse while
/// the app sits suspended in the background, and this is what notices.
private struct EntitlementRefresher: ViewModifier {
    @Environment(Store.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content.task(id: scenePhase) {
            guard scenePhase == .active else { return }
            await store.refreshEntitlements()
        }
    }
}

extension View {
    /// Rechecks what the user has unlocked each time the app comes to the foreground.
    /// Needs the `Store` in the environment.
    func refreshesEntitlementsWhenActive() -> some View {
        modifier(EntitlementRefresher())
    }
}
