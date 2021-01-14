//
//  AppEnvironment.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 18/05/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
import Combine

struct AppEnvironment {

    var services: DataServices
    var date: () -> Date
    var currentCalendar: () -> Calendar
    var formatters: Formatters
}

// MARK: - Real instance
extension AppEnvironment {

    static var real: AppEnvironment {
        .init(services: .real,
              date: Date.init,
              currentCalendar: { Calendar.current },
              formatters: .real)
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

    static var preview: AppEnvironment = AppEnvironment.fake()
    static let unitTest = AppEnvironment.fake()
}
#endif
