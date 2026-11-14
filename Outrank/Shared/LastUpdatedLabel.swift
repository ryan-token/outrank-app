//
//  LastUpdatedLabel.swift
//  Outrank
//

import SwiftUI

/// The day and time the rankings on screen were scraped, such as "Last updated Fri, Nov 13
/// at 9:02 AM", in the quiet style Compare gives its averages.
///
/// The label keeps its space while there is no date, so the content around it doesn't jump
/// when rankings arrive.
struct LastUpdatedLabel: View {
    /// When the rankings on screen were scraped; `nil` while there are none.
    let date: Date?

    /// Whether rankings are on their way, which shows a placeholder until they arrive.
    /// With no date and nothing loading, such as after a failed load, the label is blank.
    let isLoading: Bool

    /// Stands in for the date while loading, so the placeholder is as wide as a real one.
    private static let placeholderDate = Date(timeIntervalSinceReferenceDate: 0)

    private static let format = Date.FormatStyle.dateTime
        .weekday(.abbreviated)
        .month(.abbreviated)
        .day()
        .hour()
        .minute()

    var body: some View {
        Text("Last updated \(date ?? Self.placeholderDate, format: Self.format)")
            .font(.subheadline)
            // The color, not the hierarchical style: a list header is already secondary,
            // and a level below that is fainter than the averages' gray.
            .foregroundStyle(Color.secondary)
            .redacted(reason: date == nil ? .placeholder : [])
            .opacity(date == nil && !isLoading ? 0 : 1)
            .accessibilityHidden(date == nil)
            .animation(.smooth, value: date)
            .animation(.smooth, value: isLoading)
    }
}

#Preview {
    List {
        Section {
            Text("Rankings")
        } header: {
            LastUpdatedLabel(date: .now, isLoading: false)
        }

        Section {
            Text("Rankings")
        } header: {
            LastUpdatedLabel(date: nil, isLoading: true)
        }
    }
}
