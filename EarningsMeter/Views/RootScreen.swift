import DataStores
import SwiftUI
import Combine
import Models

enum TabContentSheetItem: Identifiable {
    var id: Self { self }
    case settings
    case info
}

struct RootScreen: View {
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var userPreferences: UserPreferencesDataStore
    
    let sceneChangeHandler = ScenePhaseHandler()
    
    @State private var activeSheetItem: TabContentSheetItem?
        
    var body: some View {
        TabView {
            earningsTab
            accumulatedEarningsTab
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
    
    private var earningsTab: some View {
        MeterScreen(style: .today,
                    navigationTitle: "earnings.today.navigation.title")
            .tabContentScreen(
                imageName: "dollarsign.square",
                title: "tab.title.earnings.today",
                accessibilityID: "acc.id.tab.title.earnings.today",
                activeSheetItem: $activeSheetItem
            )
    }
    
    private var accumulatedEarningsTab: some View {
        MeterScreen(style: .accumulated,
                    navigationTitle: "earnings.since.navigation.title")
            .tabContentScreen(
                imageName: "calendar",
                title: "tab.title.accumulated.earnings",
                accessibilityID: "acc.id.tab.title.accumulated.earnings",
                activeSheetItem: $activeSheetItem
            )
    }
}


#if DEBUG
#Preview {
    RootScreen()
        .environmentObject(UserPreferencesDataStore.stub(savedSettings: .placeholder))
        .withStubbedEnvironment()
}
#endif
