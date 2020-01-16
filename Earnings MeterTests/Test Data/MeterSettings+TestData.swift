//
//  MeterTime+TestData.swift
//  Earnings MeterTests
//
//  Created by Shilan Patel on 14/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

@testable import Earnings_Meter

extension AppState.MeterSettings {

    static func day_worker_0900_to_1700(withDailyRate dailyRate: Double,
                                        runAtWeekends: Bool = false) -> AppState.MeterSettings {
        
        return .init(dailyRate: dailyRate,
                     startTime: .init(hour: 9, minute: 0),
                     endTime: .init(hour: 17, minute: 0),
                     runAtWeekends: runAtWeekends)
    }
    
    static func overnight_worker_2200_to_0600(withDailyRate dailyRate: Double,
                                              runAtWeekends: Bool = false) -> AppState.MeterSettings {
        
        return .init(dailyRate: dailyRate,
                     startTime: .init(hour: 22, minute: 0),
                     endTime: .init(hour: 6, minute: 0),
                     runAtWeekends: runAtWeekends)
    }
}
