//
//  WidgetTeamSystemPicker.swift
//  Outrank
//

import SwiftUI

/// The system's menu picker for the widgets' team. `WidgetTeamPicker` shows it at the
/// accessibility text sizes and gives it to VoiceOver at every size.
struct WidgetTeamSystemPicker: View {
    @Binding var team: String

    var body: some View {
        Picker(selection: $team) {
            WidgetTeamOptions()
        } label: {
            WidgetTeamLabel()
        }
    }
}
