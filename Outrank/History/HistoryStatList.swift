//
//  HistoryStatList.swift
//  Outrank
//

import SwiftUI

/// The stat picker's rows, narrowed by the search. Choosing one charts it and goes back.
struct HistoryStatList: View {
    @Environment(HistoryModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    let searchText: String

    var body: some View {
        let stats = model.stats(matching: searchText)

        List(stats, id: \.self) { stat in
            Button {
                choose(stat)
            } label: {
                HistoryStatRow(stat: stat)
            }
            .buttonStyle(.plain)
        }
        .overlay {
            if stats.isEmpty {
                ContentUnavailableView.search
            }
        }
    }

    private func choose(_ stat: String) {
        model.stat = stat
        dismiss()
    }
}
