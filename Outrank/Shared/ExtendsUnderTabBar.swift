//
//  ExtendsUnderTabBar.swift
//  Outrank
//

import SwiftUI

extension View {
    /// Lets a tab's split view reach the top of the window, as a tab's navigation stack
    /// does by itself.
    ///
    /// Where the tab bar is at the top, on iPad and Mac, a split view's columns otherwise
    /// start below the status bar at launch and below the tab bar once the tab is switched
    /// to, with a strip of plain window background above them. The columns' own bars and
    /// content still keep clear of the status bar and the tab bar.
    func extendsUnderTabBar() -> some View {
        ignoresSafeArea(.container, edges: .top)
    }
}
