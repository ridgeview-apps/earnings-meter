import Foundation

struct MeterTime: Equatable, Codable {
    
    static func == (lhs: MeterTime, rhs: MeterTime) -> Bool {
        return lhs.hour == rhs.hour && lhs.minute == rhs.minute
    }

    
    enum CodingKeys: String, CodingKey {
        case hour, minute
    }
    
    let hour: Int
    let minute: Int
    
    init(hour: Int,
         minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    func asLocalTimeToday(environment: AppEnvironment) -> Date {
        let now = environment.date()
        let calendar = environment.currentCalendar()
        return calendar.date(bySettingHour: hour,
                             minute: minute,
                             second: 0,
                             of: now) ?? now
    }
    
    var seconds: TimeInterval {
        return TimeInterval((hour * 60 * 60) + (minute * 60))
    }
}
