//
//  SidebarList.swift
//  Outrank
//

import SwiftUI

/// A split view's sidebar list, whose rows are `SidebarRow`s.
///
/// The list only shows the selection, as the highlighted row beside the selected screen
/// in two columns. Its rows set it. Collapsed, the list gets no selection at all: a split
/// view also navigates on its sidebar list's selection, which would compete with the
/// push the rows already cause.
///
/// On the Mac the list is given no selection at any size, and the selected row draws the
/// highlight. See `SidebarHighlight`.
struct SidebarList<Value: Hashable, Content: View>: View {
    let selection: Value?
    @ContentBuilder var content: Content

    @Environment(\.splitViewIsCollapsed) private var splitViewIsCollapsed

    var body: some View {
        if SidebarHighlight.isDrawnByRows {
            List {
                content
            }
        } else {
            List(selection: .constant(splitViewIsCollapsed ? nil : selection)) {
                content
            }
        }
    }
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
}
