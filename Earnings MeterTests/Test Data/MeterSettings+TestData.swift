//
//  MeterTime+TestData.swift
//  Earnings MeterTests
//
//  Created by Shilan Patel on 14/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
@testable import Earnings_Meter

extension AppState.MeterSettings {

    static func day_worker_0900_to_1700(withDailyRate dailyRate: Double,
                                        calendar: Calendar,
                                        dateGenerator: DateGeneratorType,
                                        runAtWeekends: Bool = false) -> AppState.MeterSettings {
        
        return .fake(dailyRate: dailyRate,
                     startTime: .init(hour: 9, minute: 0, calendar: calendar, dateGenerator: dateGenerator),
                     endTime: .init(hour: 17, minute: 0, calendar: calendar, dateGenerator: dateGenerator),
                     runAtWeekends: runAtWeekends)
    }
    
    static func overnight_worker_2200_to_0600(withDailyRate dailyRate: Double,
                                              calendar: Calendar,
                                              dateGenerator: DateGeneratorType,
                                              runAtWeekends: Bool = false) -> AppState.MeterSettings {
        
        return .fake(dailyRate: dailyRate,
                     startTime: .init(hour: 22, minute: 0, calendar: calendar, dateGenerator: FakeDateGenerator()),
                     endTime: .init(hour: 6, minute: 0, calendar: calendar, dateGenerator: FakeDateGenerator()),
                     runAtWeekends: runAtWeekends)
    }
}


extension DateFormatter {
    
    static let testShortTimeStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
