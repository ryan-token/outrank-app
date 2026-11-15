//
//  SidebarRow.swift
//  Outrank
//

import SwiftUI

/// A split view sidebar row that opens the screen for `value`: pushed in compact widths,
/// beside the sidebar otherwise.
///
/// It is a button that sets the selection, not a navigation link in a list that owns the
/// selection. Such a list clears its selection as it comes back into view, which removes
/// the pushed screen the moment a swipe back is released instead of letting it settle.
struct SidebarRow<Value: Hashable, Label: View>: View {
    let value: Value
    @Binding var selection: Value?
    @ContentBuilder var label: Label

    @Environment(\.splitViewIsCollapsed) private var splitViewIsCollapsed

    var body: some View {
        Button(action: select) {
            HStack {
                if isHighlightedByRow {
                    // What a list does for the row it highlights: white text, and
                    // telling the label it sits on a fill.
                    label
                        .foregroundStyle(.white)
                        .environment(\.backgroundProminence, .increased)
                } else {
                    label
                }

                // A chevron only where rows push. Beside the sidebar, the highlighted row
                // says which screen is showing.
                if splitViewIsCollapsed {
                    Image(systemName: "chevron.forward")
                        .font(.footnote)
                        .bold()
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
            }
        }
        // Lets a list that is given the selection highlight this row.
        .tag(value)
        .listRowBackground(isHighlightedByRow ? SidebarHighlight() : nil)
        .accessibilityAddTraits(selection == value ? .isSelected : [])
    }

    /// Whether this row draws the highlight for being selected. See `SidebarHighlight`.
    private var isHighlightedByRow: Bool {
        SidebarHighlight.isDrawnByRows && !splitViewIsCollapsed && selection == value
    }

    private func select() {
        selection = value
    }
}

extension EnvironmentValues {
    /// Whether the enclosing split view is showing its columns as one stack. A split
    /// view collapses in compact widths, and its sidebar is compact at every size, so
    /// whoever owns the split view sets this from the size class outside it.
    @Entry var splitViewIsCollapsed = false
}

#Preview {
    @Previewable @State var selection: String?

    SidebarList(selection: selection) {
        SidebarRow(value: "Passing Offense", selection: $selection) {
            RankingRow(title: "Passing Offense", ranking: 97, titleFont: .headline)
        }

        SidebarRow(value: "Blocked Kicks", selection: $selection) {
            RankingRow(title: "Blocked Kicks", ranking: nil, titleFont: .headline)
        }
    }
    .environment(\.splitViewIsCollapsed, true)
}
