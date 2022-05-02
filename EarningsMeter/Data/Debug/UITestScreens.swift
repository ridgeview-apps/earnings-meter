import SwiftUI

extension UITestScenario {
    
    @ViewBuilder var launchView: some View {
        NavigationView {
            switch self {
            case .meterViewBeforeWork:
                MeterView(appViewModel: AppViewModel.fake(ofType: .meterNotYetStarted))
            case .meterViewAtWork:
                MeterView(appViewModel: AppViewModel.fake(ofType: .meterRunningAtMiddleOfDay))
            case .meterViewAfterWork:
                MeterView(appViewModel: AppViewModel.fake(ofType: .meterFinished))
            case .welcomeView:
                MeterSettingsView(appViewModel: .fake(ofType: .welcomeState))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
