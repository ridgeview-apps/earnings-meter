import SwiftUI
import Combine

struct RootView: View {

    @StateObject private var viewModel: RootViewModel = .init()
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            rootView
                .onAppear {
                    viewModel.inputs.environmentObjects.send(appViewModel)
                    viewModel.inputs.appear.send()
                }
                .sheet(isPresented: $viewModel.isAppInfoPresented) {
                    AppInfoView(appViewModel: appViewModel,
                                onDone: viewModel.inputs.closeAppInfo.send)
                        .embeddedInNavigationView()
                }
                .environmentObject(appViewModel)
                .animation(.default, value: viewModel.childViewState)
                .transition(.opacity)
        }
        .onAppear {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder var rootView: some View {
        ZStack {
            switch viewModel.childViewState {
            case .editSettings:
                MeterSettingsView(
                    onSave: { _ in
                        viewModel.inputs.closeSettings.send()
                    },
                    onTappedInfo: viewModel.inputs.goToAppInfo.send
                )
            case .meterRunning:
                MeterView(onTappedSettings: viewModel.inputs.goToSettings.send)
            }
        }
    }
}

// MARK - Previews
#if DEBUG
struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            RootView()
                .environmentObject(AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
            RootView()
                .environmentObject(AppViewModel.preview(meterSettings: nil))
        }
    }
}
#endif
