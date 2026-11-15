//
//  WidgetTeamOptions.swift
//  Outrank
//

import SwiftUI

/// Every team as a picker option, tagged with its name.
struct WidgetTeamOptions: View {
    var body: some View {
        ForEach(AllTeams.all) { team in
            Text(team.name).tag(team.name)
        }
    }
}
