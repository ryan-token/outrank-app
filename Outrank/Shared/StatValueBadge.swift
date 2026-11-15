//
//  StatValueBadge.swift
//  Outrank
//

import SwiftUI

/// The number behind a ranking, such as "534.7", in a gray capsule. Wherever a value is
/// shown beside a ranking it looks like this, so the two are never mistaken for each other.
///
/// It takes its font from where it is used, like the ranking it sits beside.
struct StatValueBadge: View {
    /// The value, already formatted.
    let value: String

    /// Neither of the ranking colors: a value isn't good or bad without its ranking. Darker
    /// than the system's gray, which white text doesn't stand out from, and the same in
    /// light and dark, where it reads against either background.
    static let background = Color(white: 0.45)

    /// How far the capsule extends past the value at its ends, and above and below it, at
    /// the default text size.
    static let padding = CGSize(width: 8, height: 2)

    /// The value as text that can go inside a sentence, for a `Text` drawn with a
    /// `StatValueBadgeRenderer`, which draws the same capsule around it.
    static func inline(_ value: String) -> Text {
        // Text can't be padded, so spaces on either side keep the words around the value
        // clear of the capsule's ends. They don't break, and neither do the ones put in
        // place of the value's own: no part of the badge can be left behind at the end of
        // a line.
        let space = "\u{00A0}"
        let room = Text(verbatim: space + space)
        let badge = Text(verbatim: value.replacing(" ", with: space))
            .monospacedDigit()
            .foregroundStyle(.white)
            .customAttribute(StatValueBadgeRenderer.Attribute())
        return Text("\(room)\(badge)\(room)")
    }

    @ScaledMetric(relativeTo: .body) private var horizontalPadding = Self.padding.width
    @ScaledMetric(relativeTo: .body) private var verticalPadding = Self.padding.height

    var body: some View {
        Text(value)
            .monospacedDigit()
            .foregroundStyle(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(Self.background, in: .capsule)
    }
}

#Preview {
    VStack(alignment: .leading) {
        StatValueBadge(value: "534.7")
        StatValueBadge(value: "58.9%")
            .font(.headline)
        StatValueBadge(value: "36.7 min")
            .font(.largeTitle)
            .bold()
    }
    .padding()
}
