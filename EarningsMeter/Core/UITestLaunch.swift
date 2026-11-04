import DataStores
import Foundation
import Models
import Shared

/// The launch configuration a UI test started the app with, or `nil` outside UI tests. Only Debug builds read it.
enum UITestLaunch {

    static let configuration: EarningsMeterUITestLaunchConfiguration? = {
        #if DEBUG
            EarningsMeterUITestLaunchConfiguration.fromProcessEnvironment()
        #else
            nil
        #endif
    }()

    static var clock: AppClock {
        configuration.map { .fixed(at: $0.now) } ?? .live
    }

    static var disablesAnimations: Bool {
        configuration?.disablesAnimations ?? false
    }
}

#if DEBUG

    extension UITestScenario.Seed {

        func write(to userDefaults: UserDefaults) {
            switch self {
            case .freshInstall:
                break
            case .returningUser:
                userDefaults.userPreferences = UserPreferences(
                    meterSettings: MeterSettings(
                        rate: .init(amount: 400, type: .daily),
                        startTime: .init(hour: 7, minute: 0),
                        endTime: .init(hour: 15, minute: 0),
                        runAtWeekends: false
                    ),
                    earningsSinceDate: Date.iso8601(
                        timeZone: TimeZone(identifier: UITestScenario.timeZoneIdentifier) ?? .utc,
                        year: 2026,
                        month: 1,
                        day: 1
                    )
                )
            }
        }
    }

#endif
