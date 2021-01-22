import SwiftUI

extension UITestScenario {
    
    @ViewBuilder var launchView: some View {
        switch self {
        case .meterViewBeforeWork:
            MeterView(appViewModel: .fake(ofType: .meterNotYetStarted))
                .embeddedInNavigationView()
        case .meterViewAtWork:
            MeterView(appViewModel: .fake(ofType: .meterRunningAtMiddleOfDay))
                .embeddedInNavigationView()
        case .meterViewAfterWork:
            MeterView(appViewModel: .fake(ofType: .meterFinished))
                .embeddedInNavigationView()
        case .welcomeView:
            MeterSettingsView(appViewModel: .fake(ofType: .welcomeState))
                .embeddedInNavigationView()
        }
    }
}
