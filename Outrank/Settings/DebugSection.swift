//
//  DebugSection.swift
//  Outrank
//

#if DEBUG
import SwiftUI

/// Switches for working on the app, shown in Settings in debug builds only.
struct DebugSection: View {
    /// Where the History switch is kept. `HistoryView` reads it too.
    static let unlocksHistoryKey = "DebugUnlocksHistory"

    @AppStorage(Self.unlocksHistoryKey) private var unlocksHistory = false

    var body: some View {
        Section {
            Toggle("Unlock History", isOn: $unlocksHistory)
        } header: {
            Text("Debug")
        } footer: {
            Text("Shows History without a subscription. The store is left alone, so purchases still test normally.")
        }
    }
}
#endif
