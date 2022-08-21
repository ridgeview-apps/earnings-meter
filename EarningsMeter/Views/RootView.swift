import SwiftUI
import Combine

struct RootView: View {
    
    @StateObject private var viewModel: RootViewModel
    @StateObject private var  appViewModel: AppViewModel
    @Environment(\.scenePhase) var scenePhase
    
    let sceneChangeHandler = ScenePhaseHandler()
    
    init(appViewModel: AppViewModel) {
        self._appViewModel = StateObject(wrappedValue: appViewModel)
        self._viewModel = StateObject(wrappedValue: RootViewModel(appViewModel: appViewModel))
    }
    
    var body: some View {
        NavigationView {
            rootView
                .sheet(isPresented: $viewModel.isAppInfoPresented) {
                    AppInfoView(appViewModel: appViewModel,
                                onDone: { viewModel.closeAppInfo() })
                        .embeddedInNavigationView()
                }
                .animation(.default, value: viewModel.navigationState)
                .transition(.opacity)

        }
        .onAppear {
            viewModel.fetchInitialDataIfNeeded()
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        .onChange(of: scenePhase) { scenePhase in
            sceneChangeHandler.scenePhaseChanged(to: scenePhase)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder var rootView: some View {
        ZStack {
            switch viewModel.navigationState {
            case .settingsHome:
                MeterSettingsView(
                    appViewModel: appViewModel,
                    onDidSave: {
                        viewModel.goToMeterHome()
                    },
                    onTappedInfo: {
                        viewModel.goToAppInfo()
                    }
                )
            case let .meterHome(settings):
                MeterHomeView(
                    viewModel: .init(meterSettings: settings),
                    onTappedSettings: {
                        viewModel.navigationState = .settingsHome
                    }
                )
            }
        }
    }
}

// MARK - Previews
#if DEBUG
struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            RootView(
                appViewModel: AppViewModel.preview(
                    meterSettings: .fake(ofType: .day_worker_0900_to_1700)
                )
            )
            RootView(
                appViewModel: AppViewModel.preview(meterSettings: nil)
            )
        }
    }
}
#endif
