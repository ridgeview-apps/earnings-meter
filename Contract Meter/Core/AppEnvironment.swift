import Foundation
import Combine

struct AppEnvironment {

    var services: DataServices
    var date: () -> Date
    var currentCalendar: () -> Calendar
    var formatters: Formatters
    var stringLocalizer: StringLocalizer
}

// MARK: - Real instance
extension AppEnvironment {

    static var real: AppEnvironment {
        .init(services: .real,
              date: Date.init,
              currentCalendar: { Calendar.current },
              formatters: .real,
              stringLocalizer: .real)
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

    static var preview: AppEnvironment {
        .init(services: .fake,
              date: Date.init,
              currentCalendar: { Calendar.current },
              formatters: .fake,
              stringLocalizer: .real)
    }
    
    static var unitTest: AppEnvironment {
        .init(services: .fake,
              date: Date.init,
              currentCalendar: { Calendar.iso8601(in: .london) },
              formatters: .fake,
              stringLocalizer: .fake)
    }
}
#endif
