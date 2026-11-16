//
//  StatValueText.swift
//  Outrank
//

import SwiftUI

/// The number behind a ranking, such as "534.7". Wherever a value is shown beside a
/// ranking it is set the way the ranking is, in gray: a value isn't good or bad without
/// its ranking, so it takes neither of the ranking colors.
///
/// It takes its font from where it is used, like the ranking it sits beside.
struct StatValueText: View {
    /// The value, already formatted.
    let value: String

    var body: some View {
        Text(value)
            .monospacedDigit()
            .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(alignment: .leading) {
        StatValueText(value: "534.7")
        StatValueText(value: "58.9%")
            .font(.headline)
        StatValueText(value: "36.7 min")
            .font(.largeTitle)
            .bold()
    }
    .padding()
}
