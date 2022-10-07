import SwiftUI
import Model

#if DEBUG
extension UITestScenario {
    
    @ViewBuilder var launchView: some View {
        NavigationView {
            EmptyView()
            switch self {
            case .meterViewBeforeWork:
                meterHomeView(now: .weekday_0200_London)
            case .meterViewAtWork:
                meterHomeView(now: .weekday_1300_London)
            case .meterViewAfterWork:
                meterHomeView(now: .weekday_1900_London)
            case .welcomeView:
                let appViewModel = AppViewModel(environment: .fake())
                MeterSettingsView(appViewModel: appViewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func meterHomeView(meterSettings: MeterSettings = .fake(ofType: .day_worker_0900_to_1700),
                               now: Date) -> MeterHomeView {
        var environment = AppEnvironment.fake()
        environment.services.meterSettings.save(meterSettings: meterSettings)
        environment.date = { now }
        return MeterHomeView(viewModel: .init(meterSettings: meterSettings,
                                              calendar: environment.currentCalendar(),
                                              now: environment.date))
    }
}
#endif
