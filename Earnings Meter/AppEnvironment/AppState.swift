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
                     startTime: MeterTime = .fake(hour: 8, minute: 10),
                     endTime: MeterTime = .fake(hour: 18, minute: 30),
                     runAtWeekends: Bool = false) -> AppState.MeterSettings {
        return .init(dailyRate: dailyRate,
                     startTime: startTime,
                     endTime: endTime,
                     runAtWeekends: runAtWeekends)
    }
}

struct MeterTime: Equatable, Codable {
    
    static func == (lhs: MeterTime, rhs: MeterTime) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }

    
    enum CodingKeys: String, CodingKey {
        case hour, minute
    }
    
    let hour: Int
    let minute: Int
    
    private(set) var calendar: Calendar = .current
    private var dateGenerator: DateGeneratorType = DateGenerator.default

    init(hour: Int,
         minute: Int,
         calendar: Calendar,
         dateGenerator: DateGeneratorType) {
        self.hour = hour
        self.minute = minute
        self.calendar = calendar
        self.dateGenerator = dateGenerator
    }
    
    var date: Date {
        let date = dateGenerator.now
        return calendar.date(bySettingHour: hour,
                             minute: minute,
                             second: 0,
                             of: date) ?? date
    }
    
    var seconds: TimeInterval {
        return TimeInterval((hour * 60 * 60) + (minute * 60))
    }
    
    // MARK: - Fakes
    static func fake(hour: Int,
                     minute: Int,
                     calendar: Calendar = .current,
                     dateGenerator: DateGeneratorType = DateGenerator.default) -> MeterTime {
        MeterTime(hour: hour, minute: minute, calendar: calendar, dateGenerator: dateGenerator)
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
