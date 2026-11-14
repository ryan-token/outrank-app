//
//  HistoryContentView.swift
//  Outrank
//

import SwiftUI

/// The History screen as a subscriber sees it: one team's ranking in one stat across a
/// season, with the choices of team, stat, and season around the chart.
struct HistoryContentView: View {
    @State private var model = HistoryModel()
    @State private var isShowingTeamPicker = false
    @State private var reloadAttempt = 0

    /// Follows the screen's height, so the chart is resized when the device is rotated,
    /// iPhone Duo is folded, or an iPad window is resized.
    @State private var chartHeight = HistoryChartArea.chartHeight(forScreenHeight: 0)

    var body: some View {
        HistoryPanes(chartHeight: chartHeight, reloadAttempt: $reloadAttempt)
            .navigationDestination(for: HistoryDestination.self) { destination in
                switch destination {
                case .statPicker:
                    // A pushed screen doesn't inherit this one's environment.
                    HistoryStatPicker()
                        .environment(model)
                }
            }
            // The chart and the views around it take the model from the environment, so each
            // depends only on what it reads and following a selection across the chart
            // doesn't update this screen.
            .environment(model)
            // The content fills the screen whatever its rows do, so sizing a row from its
            // height can't change the height being measured.
            .onGeometryChange(for: Double.self) { geometry in
                HistoryChartArea.chartHeight(forScreenHeight: geometry.size.height)
            } action: { height in
                chartHeight = height
            }
            .refreshable {
                await model.load()
            }
            .navigationTitle(model.team)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // A symbol as well as a title, so on iPhone Duo it can move into the vertical
                // bar instead of holding a horizontal bar open.
                ToolbarItem(placement: .topBarLeading) {
                    Button("Choose Team", systemImage: "american.football", action: showTeamPicker)
                        .tint(.primary)
                }
            }
            .sheet(isPresented: $isShowingTeamPicker) {
                TeamPickerView(team: $model.team)
            }
            .refreshTask(id: HistoryLoadKey(team: model.team, season: model.season, reloadAttempt: reloadAttempt)) {
                await model.loadIfStale()
            }
    }

    private func showTeamPicker() {
        isShowingTeamPicker = true
    }
}

#Preview {
    NavigationStack {
        HistoryContentView()
    }
    .environment(WindowRouter())
    .environment(\.managedObjectContext, PersistentContainer.preview.viewContext)
}
