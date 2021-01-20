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

extension MeterTime {

    static func fake(hour: Int,
                     minute: Int) -> Self {
        .init(hour: hour, minute: minute)
    }
    
}
