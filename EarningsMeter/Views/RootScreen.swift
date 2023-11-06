import DataStores
import SwiftUI
import Combine
import Models

struct RootScreen: View {
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var userPreferences: UserPreferencesDataStore
    
    let sceneChangeHandler = ScenePhaseHandler()
    
    enum SheetItem: Identifiable {
        var id: Self { self }
        case settings
        case info
    }
    
    @State private var activeSheetItem: SheetItem?
        
    var body: some View {
        TabView {
            earningsTodayScreen
            accumulatedEarningsScreen
        }
        .tint(.redThree)
        .task {
            if userPreferences.isSetUpRequired {
                activeSheetItem = .settings
            }
        }
        .onChange(of: scenePhase) { scenePhase in
            sceneChangeHandler.scenePhaseChanged(to: scenePhase)
        }
    }
    
    private var earningsTodayScreen: some View {
        tabViewContent {
            MeterScreen(style: .today,
                        navigationTitle: "earnings.today.navigation.title")
        }
        .styledTabItem(
            imageName: "dollarsign.square",
            title: "tab.title.earnings.today",
            accessibilityID: "acc.id.tab.title.earnings.today"
        )
    }
    
    private var accumulatedEarningsScreen: some View {
        tabViewContent {
            MeterScreen(style: .accumulated,
                        navigationTitle: "earnings.since.navigation.title")
        }
        .styledTabItem(
            imageName: "calendar",
            title: "tab.title.accumulated.earnings",
            accessibilityID: "acc.id.tab.title.accumulated.earnings"
        )
    }
    
    private func tabViewContent(_ content: () -> some View) -> some View {
        NavigationStack {
            content()
                .sheet(item: $activeSheetItem) {
                    show(sheetItem: $0)
                }
                .withToolbarInfoButton(placement: .topBarLeading) {
                    activeSheetItem = .info
                }
                .withToolbarSettingsButton(placement: .topBarTrailing) {
                    activeSheetItem = .settings
                }
        }
    }
    
    @ViewBuilder private func show(sheetItem: SheetItem) -> some View {
        switch sheetItem {
        case .info:
            AppInfoScreen()
        case .settings:
            MeterSettingsScreen()
        }
    }    
}

#if DEBUG
#Preview {
    RootScreen()
        .environmentObject(UserPreferencesDataStore.stub(savedSettings: .placeholder))
        .withStubbedEnvironment()
}
#endif
