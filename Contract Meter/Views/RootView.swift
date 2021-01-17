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
                .id(viewModel.childViewState)
                .transition(.opacity)
                .animation(.default)
                .onAppear {
                    viewModel.inputs.appear.send()                    
                }
        }
    }
    
    private var rootView: some View {
        switch viewModel.childViewState {
        case .editSettings:
            return SettingsView(appViewModel: appViewModel,
                                onSave: { _ in
                                    self.viewModel.inputs.closeSettings.send()
                                })
                                .eraseToAnyView()
        case .meterRunning:
            return MeterView(appViewModel: appViewModel,
                             onTappedSettings: {
                                self.viewModel.inputs.goToSettings.send()
                             })
                             .eraseToAnyView()
        }
    }
}

// MARK - Previews
#if DEBUG
struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            RootView(appViewModel: .preview(meterSettings: .fake(ofType: .weekdayOnlyMeter)))
            RootView(appViewModel: .preview(meterSettings: nil))
        }
    }
}
#endif
