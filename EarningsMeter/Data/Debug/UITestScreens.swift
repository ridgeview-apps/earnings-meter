import SwiftUI

extension UITestScenario {
    
    @ViewBuilder var launchView: some View {
        NavigationView {
            switch self {
            case .meterViewBeforeWork:
                MeterView()
                    .environmentObject(AppViewModel.fake(ofType: .meterNotYetStarted))
            case .meterViewAtWork:
                MeterView()
                    .environmentObject(AppViewModel.fake(ofType: .meterRunningAtMiddleOfDay))
            case .meterViewAfterWork:
                MeterView()
                    .environmentObject(AppViewModel.fake(ofType: .meterFinished))
            case .welcomeView:
                MeterSettingsView()
                    .environmentObject(AppViewModel.fake(ofType: .welcomeState))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
