import DataStores
import SwiftUI
import Models

enum TabContentSheetItem: Identifiable {
    var id: Self { self }
    case settings
    case info
}

struct RootScreen: View {
    
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage(UserDefaults.Keys.userPreferences.rawValue, store: AppEnvironment.shared.userDefaults)
    private var userPreferences: UserPreferences = .empty
    
    let sceneChangeHandler = ScenePhaseHandler()
    
    @State private var showSettings: Bool = false
        
    var body: some View {
        TabView {
            earningsTab
            accumulatedEarningsTab
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
    
    private var earningsTab: some View {
        MeterScreen(
            style: .today,
            navigationTitle: "earnings.today.navigation.title"
        )
        .tabContentScreen(
            imageName: "dollarsign.square",
            title: "tab.title.earnings.today",
            accessibilityID: "acc.id.tab.title.earnings.today"
        )
    }
    
    private var accumulatedEarningsTab: some View {
        MeterScreen(
            style: .accumulated,
            navigationTitle: "earnings.since.navigation.title"
        )
        .tabContentScreen(
            imageName: "calendar",
            title: "tab.title.accumulated.earnings",
            accessibilityID: "acc.id.tab.title.accumulated.earnings"
        )
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
