import Foundation
import Combine
import DeviceKit
import RidgeviewCore

struct AppEnvironment {

    var services: DataServices
    var date: () -> Date
    var currentCalendar: () -> Calendar
    var formatters: Formatters
    var stringLocalizer: StringLocalizer
    var mainBundle: Bundle
    var currentLocale: Locale
    var currentDevice: Device
    var appConfig: AppConfig
}

// MARK: - Real instance
extension AppEnvironment {

    static var real: AppEnvironment {
        .init(services: .real,
              date: Date.init,
              currentCalendar: { Calendar.current },
              formatters: .real,
              stringLocalizer: .real,
              mainBundle: Bundle.main,
              currentLocale: .current,
              currentDevice: Device.current,
              appConfig: .real)
    }
}

enum AppLaunchMode: String {
    case normal
    case preview
    case unitTest
}


// MARK: - Fake instance(s)
#if DEBUG
extension AppEnvironment {
    
    static func fake(services: DataServices = .fake,
                     date: @escaping () -> Date = Date.init,
                     currentCalendar: @escaping () -> Calendar = { Calendar.current },
                     formatters: Formatters = .fake,
                     stringLocalizer: StringLocalizer = .fake,
                     mainBundle: Bundle = .main,
                     currentLocale: Locale = .current,
                     currentDevice: Device = .current,
                     appConfig: AppConfig = .fake) -> Self {
        .init(services: services,
              date: date,
              currentCalendar: currentCalendar,
              formatters: formatters,
              stringLocalizer: stringLocalizer,
              mainBundle: mainBundle,
              currentLocale: currentLocale,
              currentDevice: currentDevice,
              appConfig: appConfig)
    }
    
    static var preview: Self {
        .fake(stringLocalizer: .real)
    }
    
    static var unitTest: Self {
        .fake(stringLocalizer: .fake)
    }
}
#endif
