//
//  PreferencesSection.swift
//  Outrank
//
//  Created by Ryan Token on 10/5/21.
//

import SwiftUI
import WidgetKit

struct PreferencesSection: View {
    @Binding var selectedDetail: SettingsDetail?

    // Stored in the app group so the widget extension can read it.
    @AppStorage(AppGroup.widgetTeamKey, store: AppGroup.defaults)
    private var widgetTeam = AppGroup.defaultWidgetTeam

    var body: some View {
        Section("Preferences") {
            MultiPicker(selectedDetail: $selectedDetail)

            Picker(selection: $widgetTeam) {
                ForEach(AllTeams.all) { team in
                    Text(team.name).tag(team.name)
                }
            } label: {
                SettingsLabel(title: "Widget", icon: "square.text.square.fill", iconColor: .purple)
            }
            .onChange(of: widgetTeam) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
