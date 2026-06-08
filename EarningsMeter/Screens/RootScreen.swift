import DataStores
import SwiftUI
import Models
import PresentationViews

enum TabContentSheetItem: Identifiable {
    var id: Self { self }
    case settings
    case info
}

struct RootScreen: View {

    @Environment(\.scenePhase) var scenePhase

    @AppStorage(UserDefaults.Keys.userPreferences.rawValue, store: .sharedTargetStorage)
    private var userPreferences: UserPreferences = .empty

    let sceneChangeHandler = ScenePhaseHandler()

    @State private var showSettings: Bool = false

    var body: some View {
        TabView {
            Tab {
                MeterScreen(style: .today)
                    .tabContentScreen()
            } label: {
                Label(
                    L10n.tabTitleEarningsToday,
                    systemImage: "gauge.with.dots.needle.bottom.50percent"
                )
            }
            .accessibilityIdentifier("acc.id.tab.title.earnings.today")

            Tab {
                MeterScreen(style: .accumulated)
                    .tabContentScreen()
            } label: {
                Label(
                    L10n.tabTitleAccumulatedEarnings,
                    systemImage: "chart.line.uptrend.xyaxis"
                )
            }
            .accessibilityIdentifier("acc.id.tab.title.accumulated.earnings")
        }
        .tint(.redThree)
        .task {
            showSettings = userPreferences.needsOnboarding
        }
        .sheet(isPresented: $showSettings) {
            MeterSettingsScreen()
        }
        .onChange(of: scenePhase) { _, scenePhase in
            sceneChangeHandler.scenePhaseChanged(to: scenePhase)
        }
    }
}


// MARK: - Previews

#Preview("Normal mode") {
    RootScreen()
        .previewWithUserPreferences(UserPreferencesStubs.nineToFiveMeter)
}

#Preview("Setup mode") {
    RootScreen()
        .previewWithUserPreferences(UserPreferences.empty)
}
