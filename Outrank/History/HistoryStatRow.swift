//
//  HistoryStatRow.swift
//  Outrank
//

import SwiftUI

/// One stat in the stat picker, checked when it is the one being charted.
struct HistoryStatRow: View {
    @Environment(HistoryModel.self) private var model

    let stat: String

    var body: some View {
        // Read here, not in the list, so choosing a stat updates the rows and not the list.
        let isSelected = stat == model.stat

        HStack {
            Text(Conversions.humanReadableStat(for: stat))
                .frame(maxWidth: .infinity, alignment: .leading)

            if isSelected {
                Image(systemName: "checkmark")
                    .bold()
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            }
        }
        // The whole row is tappable, not only its text.
        .contentShape(.rect)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    List {
        HistoryStatRow(stat: HistoryModel.defaultStat)
        HistoryStatRow(stat: "TotalDefense")
    }
    .environment(HistoryModel())
}
