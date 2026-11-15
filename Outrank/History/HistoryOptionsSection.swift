//
//  HistoryOptionsSection.swift
//  Outrank
//

import SwiftUI

/// The History screen's choices of stat and season.
struct HistoryOptionsSection: View {
    @Environment(HistoryModel.self) private var model

    var body: some View {
        @Bindable var model = model

        Section {
            // There are dozens of stats, so they get a screen of their own, with a search
            // field, rather than a menu.
            NavigationLink(value: HistoryDestination.statPicker) {
                LabeledContent("Stat", value: Conversions.humanReadableStat(for: model.stat))
            }

            // Nothing to choose from until a season has loaded.
            if !model.seasons.isEmpty {
                Picker("Season", selection: $model.selectedSeason) {
                    ForEach(model.seasons, id: \.self) { season in
                        Text(season)
                            .tag(Optional(season))
                    }
                }
            }
        }
    }
}
