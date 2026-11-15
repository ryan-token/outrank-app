//
//  SidebarHighlight.swift
//  Outrank
//

import SwiftUI

/// The fill behind the selected `SidebarRow` when the rows draw the highlight themselves,
/// shaped like the one a sidebar list draws on the Mac.
struct SidebarHighlight: View {
    /// Whether rows draw the highlight, instead of the list that holds them.
    ///
    /// True on the Mac. There a click selects the row in the list itself as well as
    /// pressing its button, and the list then highlighted the row selected before the
    /// click, whatever selection it was given and whenever it was given it.
    static let isDrawnByRows = ProcessInfo.processInfo.isiOSAppOnMac

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.tint)
    }
}

#Preview {
    SidebarHighlight()
        .frame(height: 44)
}
