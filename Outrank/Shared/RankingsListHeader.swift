//
//  RankingsListHeader.swift
//  Outrank
//

import SwiftUI

/// What heads the Rankings list: the order it is in and, more quietly beneath that, when
/// the rankings were last updated.
struct RankingsListHeader: View {
    /// When the rankings in the list were scraped; `nil` while there are none.
    let lastUpdated: Date?

    /// Whether rankings are on their way. See `LastUpdatedLabel`.
    let isLoading: Bool

    /// The order the list is in, such as "Stat (A → Z)".
    let sortLabel: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Sorted by \(sortLabel)")
            LastUpdatedLabel(date: lastUpdated, isLoading: isLoading)
        }
    }
}

#Preview {
    List {
        Section {
            Text("Rankings")
        } header: {
            RankingsListHeader(lastUpdated: .now, isLoading: false, sortLabel: "Stat (A → Z)")
        }
    }
}
