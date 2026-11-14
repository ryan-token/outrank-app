//
//  HistoryView.swift
//  Outrank
//

import SwiftUI

/// The History tab. History is included with every subscription, so this shows the
/// charts to a subscriber and the way to subscribe to everyone else.
struct HistoryView: View {
    @Environment(Store.self) private var store

    @State private var isShowingPaywall = false

    #if DEBUG
    @AppStorage(DebugSection.unlocksHistoryKey) private var isUnlockedForDebugging = false
    #endif

    /// What the store reports, unless the debug switch in Settings has unlocked History.
    private var access: SubscriptionAccess {
        #if DEBUG
        if isUnlockedForDebugging { return .subscribed }
        #endif
        return store.subscriptionAccess
    }

    var body: some View {
        NavigationStack {
            switch access {
            case .subscribed:
                HistoryContentView()
            case .notSubscribed:
                HistoryLockedView(isShowingPaywall: $isShowingPaywall)
            case .unknown:
                // Entitlements are read from the device at launch, so this is rarely on
                // screen long enough to see. Showing neither screen until they are known
                // keeps a subscriber from being flashed the locked one.
                ProgressView()
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            HistoryPaywallView()
        }
        // A purchase or a restore in the paywall reaches the store, not this view, so
        // the paywall closes when the store says History is unlocked.
        .onChange(of: store.subscriptionAccess) { _, access in
            if access == .subscribed {
                isShowingPaywall = false
            }
        }
        .sensoryFeedback(.success, trigger: isShowingPaywall) { wasShowing, isShowing in
            wasShowing && !isShowing && store.subscriptionAccess == .subscribed
        }
    }
}

#Preview {
    HistoryView()
        .environment(Store())
        .environment(WindowRouter())
        .environment(\.managedObjectContext, PersistentContainer.preview.viewContext)
}
