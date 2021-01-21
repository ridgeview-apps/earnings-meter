import SwiftUI
import Combine

struct RootView: View {

    @ObservedObject private var viewModel: RootViewModel
    @StateObject var appViewModel: AppViewModel
    
    init(appViewModel: AppViewModel) {
        self._appViewModel = .init(wrappedValue: appViewModel)
        self.viewModel = RootViewModel(appViewModel: appViewModel)
    }
    
    var body: some View {
        NavigationView {
            rootView
                .onAppear {
                    viewModel.inputs.appear.send()                    
                }
                .sheet(isPresented: $viewModel.isAppInfoPresented) {
                    AppInfoView(appViewModel: appViewModel,
                                onDone: viewModel.inputs.closeAppInfo.send)
                        .embeddedInNavigationView()
                }
                .animation(.default)
                .transition(.opacity)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder var rootView: some View {
        ZStack {
            switch viewModel.childViewState {
            case .editSettings:
                MeterSettingsView(appViewModel: appViewModel,
                             onSave: { _ in
                                viewModel.inputs.closeSettings.send()
                             },
                             onTappedInfo: viewModel.inputs.goToAppInfo.send)
            case .meterRunning:
                MeterView(appViewModel: appViewModel,
                          onTappedSettings: viewModel.inputs.goToSettings.send)
            }
        }
    }
}

// MARK - Previews
#if DEBUG
struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            RootView(appViewModel: .preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
            RootView(appViewModel: .preview(meterSettings: nil))
        }
    }
}
#endif
