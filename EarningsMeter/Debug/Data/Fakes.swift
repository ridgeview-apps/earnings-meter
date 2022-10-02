import Foundation
import Model
import ModelStubs

#if DEBUG
extension AppViewModel {
    
    enum FakeType {
        case meterNotYetStarted
        case meterRunningAtMiddleOfDay
        case meterFinished
        case welcomeState
    }
    
    static func fake(environment: AppEnvironment = .preview) -> Self {
        .init(environment: environment)
    }
    
    static func fake(ofType fakeType: FakeType) -> Self {
        switch fakeType {
        case .meterNotYetStarted:
            let meterSettings = MeterSettings.fake(ofType: .day_worker_0900_to_1700)
            let environment = AppEnvironment.fake(date: { Date.weekday_0200_London })
            environment.services.meterSettings.save(meterSettings: meterSettings)
            return .fake(environment: environment)
        case .meterRunningAtMiddleOfDay:
            let meterSettings = MeterSettings.fake(ofType: .day_worker_0900_to_1700)
            let environment = AppEnvironment.fake(date: { Date.weekday_1300_London })
            environment.services.meterSettings.save(meterSettings: meterSettings)
            return .fake(environment: environment)
        case .meterFinished:
            let meterSettings = MeterSettings.fake(ofType: .day_worker_0900_to_1700)
            let environment = AppEnvironment.fake(date: { Date.weekday_1900_London })
            environment.services.meterSettings.save(meterSettings: meterSettings)
            return .fake(environment: environment)
        case .welcomeState:
            let environment = AppEnvironment.fake()
            return .fake(environment: environment)
        }
    }
}
#endif
