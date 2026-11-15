//
//  MultiPickerView.swift
//  Outrank
//
//  Created by Ryan Token on 10/5/21.
//

import SwiftUI

/// Lets the user star and unstar teams; starred teams appear first in the team picker.
struct MultiPickerView: View {
    @State private var search = TeamSearch()

    var body: some View {
        // The list reads the search; this view only owns it. Typing therefore updates
        // the rows and leaves the screen around them alone.
        FavoriteTeamsList(search: search)
            .searchable(text: $search.text, prompt: "Search Teams")
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MultiPickerView()
            .environment(\.managedObjectContext, PersistentContainer.preview.viewContext)
    }
}
