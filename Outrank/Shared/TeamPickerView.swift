//
//  TeamPickerView.swift
//  Outrank
//
//  Created by Ryan Token on 10/2/21.
//

import SwiftUI

/// A sheet for choosing a team, with the user's favorites first. Writes the choice to
/// `team`; whoever owns that binding decides how to store it.
struct TeamPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var team: String

    @State private var search = TeamSearch()

    var body: some View {
        NavigationStack {
            // The list reads the search; this view only owns it. Typing therefore
            // updates the rows and leaves the sheet around them alone.
            TeamPickerList(search: search, team: $team)
                .searchable(text: $search.text, prompt: "Search Teams")
                #if DEBUG
                .onAppear {
                    if let text = ScreenshotMode.teamSearch {
                        search.text = text
                    }
                }
                #endif
                .navigationTitle("Choose Team")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(role: .close, action: dismiss.callAsFunction)
                    }
                }
        }
    }
}

#Preview {
    TeamPickerView(team: .constant("Tulsa"))
        .environment(WindowRouter())
        .environment(\.managedObjectContext, PersistentContainer.preview.viewContext)
}
