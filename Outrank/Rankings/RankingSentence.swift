//
//  RankingSentence.swift
//  Outrank
//

import SwiftUI

/// Says where a team ranks in a stat in so many words, with the value that put it there:
/// "Tulsa is 67th in the country in Total Offense with an average of 402.1."
struct RankingSentence: View {
    let team: String

    /// The stat's readable name.
    let stat: String

    let ranking: Int

    /// The team's value in the stat, already formatted. `nil` when it has none.
    let value: String?

    /// What kind of number the value is, which decides how the sentence introduces it.
    let valueFormat: StatValueFormat

    var body: some View {
        let ranking = Conversions.humanReadableRanking(for: ranking)

        Group {
            if let value {
                // The same words that head the table's column of values.
                switch valueFormat {
                case .count:
                    Text("\(team) is \(ranking) in the country in \(stat) with a total of \(value).")
                case .decimal, .minutes:
                    Text("\(team) is \(ranking) in the country in \(stat) with an average of \(value).")
                case .percent:
                    Text("\(team) is \(ranking) in the country in \(stat) at \(value).")
                case .rating:
                    Text("\(team) is \(ranking) in the country in \(stat) with a rating of \(value).")
                case .unlisted:
                    Text("\(team) is \(ranking) in the country in \(stat) with \(value).")
                }
            } else {
                Text("\(team) is \(ranking) in the country in \(stat).")
            }
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    List {
        RankingSentence(
            team: "Tulsa", stat: "Total Offense", ranking: 67, value: "402.1", valueFormat: .decimal(places: 1)
        )
        RankingSentence(
            team: "Tulsa", stat: "Time Of Possession", ranking: 121, value: "27.7 min", valueFormat: .minutes
        )
        RankingSentence(team: "Tulsa", stat: "Turnovers Gained", ranking: 12, value: "21", valueFormat: .count)
        RankingSentence(team: "Tulsa", stat: "Red Zone Offense", ranking: 40, value: "87.5%", valueFormat: .percent)
        RankingSentence(team: "Tulsa", stat: "Total Offense", ranking: 67, value: nil, valueFormat: .unlisted)
    }
}
