//import SwiftUI
//import Models
//
//#if DEBUG
//extension UITestScenario {
//    
//    #warning("FIX OR REMOVE LATER")
//    @ViewBuilder var launchView: some View {
//        NavigationView {
//            EmptyView()
//            switch self {
//            case .meterViewBeforeWork:
//                meterHomeView(now: DateStubs.weekday_0200_London)
//            case .meterViewAtWork:
//                meterHomeView(now: DateStubs.weekday_1300_London)
//            case .meterViewAfterWork:
//                meterHomeView(now: DateStubs.weekday_1900_London)
//            case .welcomeView:
//                let appViewModel = AppViewModel(environment: .fake())
//                Text("REMOVE LATER")
////                MeterSettingsView(appViewModel: appViewModel)
//            }
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//    
//    private func meterHomeView(meterSettings: MeterSettings = ModelStubs.dayTime_0900_to_1700(),
//                               now: Date) -> MeterHomeView {
//        var environment = AppEnvironment.fake()
//        environment.services.meterSettings.save(meterSettings: meterSettings)
//        environment.date = { now }
//        return MeterHomeView(viewModel: .init(meterSettings: meterSettings,
//                                              calendar: environment.currentCalendar(),
//                                              now: environment.date))
//    }
//}
//#endif
