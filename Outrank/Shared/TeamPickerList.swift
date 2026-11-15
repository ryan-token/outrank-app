//
//  TeamPickerList.swift
//  Outrank
//

import CoreData
import OSLog
import SwiftUI

/// The team picker's rows: the user's favorites, then every team, both narrowed by the
/// search. Choosing a row writes it to `team` and closes the picker.
///
/// The search field itself belongs to `TeamPickerView`, so typing in it updates this list
/// and nothing around it.
struct TeamPickerList: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss
    @Environment(WindowRouter.self) private var router

    @FetchRequest(fetchRequest: Favorite.allFavoritesFetchRequest, animation: .default)
    private var favorites: FetchedResults<Favorite>

    let search: TeamSearch
    @Binding var team: String

    @State private var chooseHapticTrigger = 0
    @State private var isShowingRemoveError = false

    private static let logger = Logger(category: "TeamPickerList")

    var body: some View {
        // A user's favorites are a handful of teams, so narrowing them here costs little.
        let matchingFavorites = favorites.uniquedByTeam().filter { search.matches($0.team) }

        List {
            if !search.isSearching || !matchingFavorites.isEmpty {
                Section("Favorite Teams") {
                    ForEach(matchingFavorites) { favorite in
                        Button {
                            choose(favorite.team)
                        } label: {
                            TeamPickerRow(team: favorite.team, isFavorite: true)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        removeFavorites(at: offsets, in: matchingFavorites)
                    }

                    if favorites.isEmpty {
                        Button("Choose favorites in Settings", systemImage: "gear", action: openFavoritesSettings)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if search.hasMatchingTeams {
                Section("All Teams") {
                    ForEach(search.matchingTeams) { fbsTeam in
                        Button {
                            choose(fbsTeam.name)
                        } label: {
                            TeamPickerRow(team: fbsTeam.name, isFavorite: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .overlay {
            // A favorite can be a team the list no longer has, so it counts as a result too.
            if !search.hasMatchingTeams && matchingFavorites.isEmpty {
                ContentUnavailableView.search
            }
        }
        .sensoryFeedback(.success, trigger: chooseHapticTrigger)
        .alert("Couldn't Remove Favorite", isPresented: $isShowingRemoveError) {
        } message: {
            Text("Please try again.")
        }
    }

    private func choose(_ selectedTeam: String) {
        team = selectedTeam
        chooseHapticTrigger += 1
        dismiss()
    }

    private func openFavoritesSettings() {
        dismiss()
        router.openSettings(.favorites)
    }

    /// - Parameter shownFavorites: The favorites as listed, possibly narrowed by a search,
    ///   which `offsets` index into.
    private func removeFavorites(at offsets: IndexSet, in shownFavorites: [Favorite]) {
        // Map row offsets to team names, then delete ALL favorites with that
        // team name. This cleans up any duplicate rows in a single swipe.
        let teamsToRemove = Set(offsets.map { shownFavorites[$0].team })
        for favorite in favorites where teamsToRemove.contains(favorite.team) {
            moc.delete(favorite)
        }

        do {
            try moc.saveIfNeeded()
        } catch {
            moc.rollback()
            Self.logger.error("Failed to remove favorites: \(String(describing: error))")
            isShowingRemoveError = true
        }
    }
}
