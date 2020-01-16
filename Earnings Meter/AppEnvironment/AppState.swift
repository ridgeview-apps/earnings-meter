//
//  AppState.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 30/05/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var userData = UserData()
}

extension AppState {
    
    struct MeterSettings: Codable, Equatable {
        let dailyRate: Double
        let startTime: MeterTime
        let endTime: MeterTime
        let runAtWeekends: Bool
    }

    struct UserData: Codable, Equatable {
        var meterSettings: MeterSettings?
    }
}

extension AppState.MeterSettings {
    
    static func fake(dailyRate: Double = 400,
                     startTime: MeterTime = .init(hour: 10, minute: 0),
                     endTime: MeterTime = .init(hour: 18, minute: 30),
                     runAtWeekends: Bool = false) -> AppState.MeterSettings {
        return .init(dailyRate: dailyRate,
                     startTime: startTime,
                     endTime: endTime,
                     runAtWeekends: runAtWeekends)
    }
}

struct MeterTime: Equatable, Codable {
    let hour: Int
    let minute: Int
    
    func asDateTimeToday(in calendar: Calendar = .current,
                         dateGenerator: DateGeneratorType = DateGenerator.default) -> Date {
        let date = dateGenerator.now()
        return calendar.date(bySettingHour: hour,
                             minute: minute,
                             second: 0,
                             of: date) ?? date
    }
    
    var seconds: TimeInterval {
        return TimeInterval((hour * 60 * 60) + (minute * 60))
    }
}

extension MeterTime {
    init(date: Date,
         calendar: Calendar) {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        self.hour = comps.hour ?? 0
        self.minute = comps.minute ?? 0
    }
}
