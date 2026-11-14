//
//  HistoryStatRow.swift
//  Outrank
//

import SwiftUI

/// One stat in the stat picker, checked when it is the one being charted.
struct HistoryStatRow: View {
    let stat: String
    let isSelected: Bool

    var body: some View {
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
        HistoryStatRow(stat: "ScoringOffense", isSelected: true)
        HistoryStatRow(stat: "TotalDefense", isSelected: false)
    }
}
