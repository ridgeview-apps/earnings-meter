import Foundation

extension MeterSettings {
    
    enum FakeType {
        case weekdayOnlyMeter
        case sevenDayMeter
    }
    
    static func fake(ofType fakeType: FakeType) -> Self {
        switch fakeType {
        case .weekdayOnlyMeter:
            return .fake(runAtWeekends: false)
        case .sevenDayMeter:
            return .fake(runAtWeekends: true)
        }
    }
    
    static func fake(dailyRate: Double = 400,
                     startTime: MeterTime = .fake(hour: 8, minute: 10),
                     endTime: MeterTime = .fake(hour: 18, minute: 30),
                     runAtWeekends: Bool = false) -> Self {
        .init(dailyRate: dailyRate,
              startTime: startTime,
              endTime: endTime,
              runAtWeekends: runAtWeekends)
    }
}

extension MeterTime {

    static func fake(hour: Int,
                     minute: Int) -> Self {
        .init(hour: hour, minute: minute)
    }
    
}

extension AppEnvironment {
    
    static func fake(services: DataServices = .fake,
                         date: @escaping () -> Date = Date.init,
                         currentCalendar: @escaping () -> Calendar = { Calendar.current },
                         formatters: Formatters = .fake) -> AppEnvironment {
        .init(services: services,
              date: date,
              currentCalendar: currentCalendar,
              formatters: formatters)
    }
}
