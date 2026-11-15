//
//  WidgetTeamPicker.swift
//  Outrank
//

import SwiftUI

/// The Settings row that chooses the widgets' team.
///
/// A menu picker in a list moves its value to a second line when the title and the value
/// don't fit side by side, as with "Southern California" in the iPad sidebar. This row
/// keeps the value beside the title at every width, shrinking a long name first.
///
/// At the accessibility text sizes one line can't hold both, so the row is the system
/// picker, which puts the value under the title.
struct WidgetTeamPicker: View {
    @Binding var team: String

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            WidgetTeamSystemPicker(team: $team)
        } else {
            HStack {
                WidgetTeamLabel()
                    .layoutPriority(1)

                Spacer()

                Menu {
                    Picker("Widget Team", selection: $team) {
                        WidgetTeamOptions()
                    }
                } label: {
                    Label {
                        Text(team)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    } icon: {
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .labelStyle(.trailingIcon)
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            // VoiceOver gets the system picker this row stands in for: one element
            // that reads the title and the chosen team.
            .accessibilityRepresentation {
                WidgetTeamSystemPicker(team: $team)
            }
        }
    }
}

#Preview {
    @Previewable @State var team = "Southern California"

    List {
        WidgetTeamPicker(team: $team)
    }
}
