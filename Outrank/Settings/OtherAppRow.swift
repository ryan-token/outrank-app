//
//  OtherAppRow.swift
//  Outrank
//
//  Created by Ryan Token on 10/6/21.
//

import SwiftUI

struct OtherAppRow: View {
    let image: ImageResource
    let title: String
    let subtitle: String

    @ScaledMetric(relativeTo: .headline) private var iconSize = 60

    var body: some View {
        HStack {
            // A render of the app's icon that already carries the system icon shape, so it
            // needs no clipping here.
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(subtitle)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(.rect)
    }
}
