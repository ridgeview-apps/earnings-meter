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
    
    @AppStorage(UserDefaults.Keys.userPreferences.rawValue, store: .sharedTargetStorage)
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
            navigationTitle: .earningsTodayNavigationTitle
        )
        .tabContentScreen(
            imageName: "dollarsign.square",
            title: .tabTitleEarningsToday,
            accessibilityID: "acc.id.tab.title.earnings.today"
        )
    }
    
    private var accumulatedEarningsTab: some View {
        MeterScreen(
            style: .accumulated,
            navigationTitle: .earningsSinceNavigationTitle
        )
        .tabContentScreen(
            imageName: "calendar",
            title: .tabTitleAccumulatedEarnings,
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
