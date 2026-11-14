//
//  HistoryStatPicker.swift
//  Outrank
//

import SwiftUI

/// The screen for choosing which stat History charts. There are dozens, so they can be
/// searched by name.
struct HistoryStatPicker: View {
    @State private var searchText = ""

    var body: some View {
        // The list reads the search; this view only owns it. Typing therefore updates
        // the rows and leaves the screen around them alone.
        HistoryStatList(searchText: searchText)
            // Always in the navigation bar: with the tab bar along the bottom, the default
            // placement leaves the field hidden until the list is pulled down.
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search Stats"
            )
            .navigationTitle("Stat")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HistoryStatPicker()
            .environment(HistoryModel())
    }
}
