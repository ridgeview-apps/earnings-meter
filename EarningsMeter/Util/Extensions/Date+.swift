import Foundation

// MARK: - Date
extension Date {
    static func timeDiff(between date1: Date, and date2: Date) -> TimeInterval {
        return abs(date1.timeIntervalSince1970 - date2.timeIntervalSince1970)
    }
    
    func minutesLater(_ numberOfMinutes: Int) -> Date {
        self.addingTimeInterval(.minutes(numberOfMinutes))
    }
    
    func minutesAgo(_ numberOfMinutes: Int) -> Date {
        self.addingTimeInterval(.minutes(-1 * numberOfMinutes))
    }
    
    static func UTC(year: Int = 1970,
                    month: Int = 1,
                    day: Int = 1,
                    hour: Int = 0,
                    minute: Int = 0,
                    second: Int = 0,
                    nanosecond: Int = 0) -> Date? {
        
        iso8601(timeZone: TimeZone(abbreviation: "UTC")!,
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                nanosecond: nanosecond)
    }
    
    static func iso8601(timeZone: TimeZone,
                        year: Int = 1970,
                        month: Int = 1,
                        day: Int = 1,
                        hour: Int = 0,
                        minute: Int = 0,
                        second: Int = 0,
                        nanosecond: Int = 0) -> Date? {
        
        var calendar = Calendar.iso8601
        calendar.timeZone = timeZone
        
        let comps = DateComponents(year: year,
                                   month: month,
                                   day: day,
                                   hour: hour,
                                   minute: minute,
                                   second: second,
                                   nanosecond: nanosecond)
        return calendar.date(from: comps)
    }
}

extension TimeZone {
    
    static let UTC = TimeZone(abbreviation: "UTC")!
    static let newYork = TimeZone(identifier: "America/New_York")!
    static let london = TimeZone(identifier: "Europe/London")!
}


extension Calendar {

    static let iso8601 = Calendar(identifier: .iso8601)

    static func iso8601(in timeZone: TimeZone = .UTC) -> Calendar {
        var cal = Calendar.iso8601
        cal.timeZone = timeZone
        return cal
    }
}
