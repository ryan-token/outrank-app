//
//  AboutView.swift
//  Outrank
//
//  Created by Ryan Token on 10/6/21.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            // The form owns the whole sheet, header included, so everything scrolls
            // together on short windows and at large text sizes.
            Form {
                Section {
                    AboutHeader()
                }
                .listRowBackground(Color.clear)

                Section {
                    Text("""
                        I built Outrank because I needed it. I wanted a way to quickly & easily find where my \
                        favorite teams stacked up, but nothing out there was any good.
                        """)
                    Text("""
                        This is a passion project that I've put a lot of care into over the years. I hope you enjoy it.
                        """)
                }

                Section("Try my other apps") {
                    Link(destination: AppLinks.catchUp) {
                        OtherAppRow(
                            image: .catchUp,
                            title: "CatchUp: Keep in Touch",
                            subtitle: "Personal relationship manager"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Try out this developer's other app, CatchUp: Keep in Touch")

                    Link(destination: AppLinks.hotLocalFood) {
                        OtherAppRow(
                            image: .HLF,
                            title: "Hot Local Food: Find Dinner",
                            subtitle: "Swipe & discover restaurants"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Try out this developer's other app, Hot Local Food: Find Dinner")

                    Link(destination: AppLinks.youHQ) {
                        OtherAppRow(
                            image: .youHQ,
                            title: "YouHQ: Life Organizer",
                            subtitle: "Track homes, vehicles, money"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Try out this developer's other app, YouHQ: Life Organizer")
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close, action: dismiss.callAsFunction)
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
