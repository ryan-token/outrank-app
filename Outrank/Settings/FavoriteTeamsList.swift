//
//  FavoriteTeamsList.swift
//  Outrank
//

import CoreData
import OSLog
import SwiftUI

/// The Favorites screen's rows: the starred teams, then every team, both narrowed by the
/// search. Tapping a row stars or unstars its team.
///
/// The search field itself belongs to `MultiPickerView`, so typing in it updates this
/// list and nothing around it.
struct FavoriteTeamsList: View {
    @Environment(\.managedObjectContext) private var moc

    @FetchRequest(fetchRequest: Favorite.allFavoritesFetchRequest, animation: .default)
    private var favorites: FetchedResults<Favorite>

    let search: TeamSearch

    @State private var isShowingSaveError = false

    private static let logger = Logger(category: "FavoriteTeamsList")

    var body: some View {
        // Built once per update, not once per row in the 130-plus row team list below.
        // A user's favorites are a handful of teams, so both cost little.
        let favoriteTeamNames = Set(favorites.map(\.team))
        let matchingFavorites = favorites.uniquedByTeam().filter { search.matches($0.team) }

        List {
            if !search.isSearching || !matchingFavorites.isEmpty {
                Section("Favorite Teams") {
                    ForEach(matchingFavorites) { favorite in
                        Button {
                            toggleSelection(team: favorite.team)
                        } label: {
                            FavoriteTeamRow(team: favorite.team, isFavorite: true)
                        }
                        .buttonStyle(.plain)
                    }

                    if favorites.isEmpty {
                        Text("No favorites yet ☹️")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if search.hasMatchingTeams {
                Section("All Teams") {
                    ForEach(search.matchingTeams) { team in
                        Button {
                            toggleSelection(team: team.name)
                        } label: {
                            FavoriteTeamRow(team: team.name, isFavorite: favoriteTeamNames.contains(team.name))
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
        .alert("Couldn't Update Favorites", isPresented: $isShowingSaveError) {
        } message: {
            Text("Please try again.")
        }
    }

    private func toggleSelection(team: String) {
        let matching = favorites.filter { $0.team == team }
        if matching.isEmpty {
            let favorite = Favorite(context: moc)
            favorite.team = team
            favorite.createdAt = .now
        } else {
            // Delete any/all matching rows. This both un-favorites the team and
            // self-heals any duplicate rows that may have accumulated.
            matching.forEach(moc.delete)
        }

        do {
            try moc.saveIfNeeded()
        } catch {
            moc.rollback()
            Self.logger.error("Failed to save favorites: \(String(describing: error))")
            isShowingSaveError = true
        }
    }
}
