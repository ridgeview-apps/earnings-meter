import SwiftUI

extension UITestScenario {
    
    @ViewBuilder var launchView: some View {
        NavigationView {
            EmptyView() // SHILANTODO
//            switch self {
//            case .meterViewBeforeWork:
//                MeterHomeView(appViewModel: AppViewModel.fake(ofType: .meterNotYetStarted))
//            case .meterViewAtWork:
//                MeterHomeView(appViewModel: AppViewModel.fake(ofType: .meterRunningAtMiddleOfDay))
//            case .meterViewAfterWork:
//                MeterHomeView(appViewModel: AppViewModel.fake(ofType: .meterFinished))
//            case .welcomeView:
//                MeterSettingsView(appViewModel: .fake(ofType: .welcomeState))
//            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
