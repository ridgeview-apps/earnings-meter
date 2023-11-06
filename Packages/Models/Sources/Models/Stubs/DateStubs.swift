import Foundation
import RidgeviewCore

public enum DateStubs {} // Namespace

public extension DateStubs {
    static let weekday_0200_London = Date.weekday(hour: 2, minute: 0, in: .london)
    
    static let weekday_0800_London = Date.weekday(hour: 8, minute: 0, in: .london)
    
    static let weekday_1300_London = Date.weekday(hour: 13, minute: 0, in: .london)

    static let weekday_1900_London = Date.weekday(hour: 19, minute: 0, in: .london)
    
    static let weekend_1300_London = Date.weekend(hour: 13, minute: 0, in: .london)

    static func UTC(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0, nanoSecond: Int = 0) -> Date? {
        Date.UTC(year: year, month: month, day: day, hour: hour, minute: minute, second: second, nanosecond: nanoSecond)
    }
}

private extension Date {
    
    static func weekday(hour: Int,
                        minute: Int,
                        in timeZone: TimeZone) -> Date {
        Date.iso8601(timeZone: timeZone,
                     year: 2020,
                     month: 7,
                     day: 14,
                     hour: hour,
                     minute: minute)!
    }
    
    static func weekend(hour: Int,
                        minute: Int,
                        in timeZone: TimeZone) -> Date {
        Date.iso8601(timeZone: timeZone,
                     year: 2020,
                     month: 7,
                     day: 12,
                     hour: hour,
                     minute: minute)!
    }
}

public extension TimeZone {
    static let london = TimeZone(identifier: "Europe/London")!
}
