import SwiftUI

extension UITestScenario {
    
    @ViewBuilder var launchView: some View {
        switch self {
        case .meterViewBeforeWork:
            MeterView()
                .environmentObject(AppViewModel.fake(ofType: .meterNotYetStarted))
                .embeddedInNavigationView()
        case .meterViewAtWork:
            MeterView()
                .environmentObject(AppViewModel.fake(ofType: .meterRunningAtMiddleOfDay))
                .embeddedInNavigationView()
        case .meterViewAfterWork:
            MeterView()
                .environmentObject(AppViewModel.fake(ofType: .meterFinished))
                .embeddedInNavigationView()
        case .welcomeView:
            MeterSettingsView()
                .environmentObject(AppViewModel.fake(ofType: .welcomeState))
                .embeddedInNavigationView()
        }
        EmptyView()
    }
}
