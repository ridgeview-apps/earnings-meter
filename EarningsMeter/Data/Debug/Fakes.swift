import Foundation

extension MeterSettings {
    
    enum FakeType {
       case day_worker_0900_to_1700
       case overnight_worker_2200_to_0600
    }
    
    static func fake(ofType fakeType: FakeType,
                     rate: MeterSettings.Rate = .init(amount: 400, type: .daily),
                     runAtWeekends: Bool = false) -> Self {
        switch fakeType {
        case .day_worker_0900_to_1700:
            return .fake(rate: rate,
                         startTime: .init(hour: 9, minute: 0),
                         endTime: .init(hour: 17, minute: 0),
                         runAtWeekends: runAtWeekends)
        case .overnight_worker_2200_to_0600:
            return .fake(rate: rate,
                         startTime: .init(hour: 22, minute: 0),
                         endTime: .init(hour: 6, minute: 0),
                         runAtWeekends: runAtWeekends)
        }
    }
    
    static func fake(rate: Rate = .init(amount: 40_000, type: .annual),
                     startTime: MeterTime = .fake(hour: 8, minute: 10),
                     endTime: MeterTime = .fake(hour: 18, minute: 30),
                     runAtWeekends: Bool = false) -> Self {
        .init(rate: rate,
              startTime: startTime,
              endTime: endTime,
              runAtWeekends: runAtWeekends)
    }
}

extension AppViewModel {
    
    enum FakeType {
        case meterNotYetStarted
        case meterRunningAtMiddleOfDay
        case meterFinished
        case welcomeState
    }
    
    static func fake(meterSettings: MeterSettings? = .fake(),
                     environment: AppEnvironment = .preview) -> Self {
        .init(meterSettings: meterSettings,
              environment: environment)
    }
    
    static func fake(ofType fakeType: FakeType) -> Self {
        switch fakeType {
        case .meterNotYetStarted:
            let meterSettings = MeterSettings.fake(ofType: .day_worker_0900_to_1700)
            let environment = AppEnvironment.fake(date: { Date.weekday_0200_London })
            return .fake(meterSettings: meterSettings, environment: environment)
        case .meterRunningAtMiddleOfDay:
            let meterSettings = MeterSettings.fake(ofType: .day_worker_0900_to_1700)
            let environment = AppEnvironment.fake(date: { Date.weekday_1300_London })
            return .fake(meterSettings: meterSettings, environment: environment)
        case .meterFinished:
            let meterSettings = MeterSettings.fake(ofType: .day_worker_0900_to_1700)
            let environment = AppEnvironment.fake(date: { Date.weekday_1900_London })
            return .fake(meterSettings: meterSettings, environment: environment)
        case .welcomeState:
            let environment = AppEnvironment.fake()
            return .fake(meterSettings: nil, environment: environment)
        }
    }
}

extension MeterTime {

    static func fake(hour: Int,
                     minute: Int) -> Self {
        .init(hour: hour, minute: minute)
    }
    
}

extension Date {
    
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
    
    static let weekday_0200_London = Date.weekday(hour: 2, minute: 0, in: .london)
    
    static let weekday_0800_London = Date.weekday(hour: 8, minute: 0, in: .london)
    
    static let weekday_1300_London = Date.weekday(hour: 13, minute: 0, in: .london)

    static let weekday_1900_London = Date.weekday(hour: 19, minute: 0, in: .london)
    
    static let weekend_1300_London = Date.weekend(hour: 13, minute: 0, in: .london)
}
