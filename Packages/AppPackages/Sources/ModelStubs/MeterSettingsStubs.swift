import Foundation
import Model

public extension MeterSettings {
    
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
                     startTime: MeterSettings.MeterTime = .fake(hour: 8, minute: 10),
                     endTime: MeterSettings.MeterTime = .fake(hour: 18, minute: 30),
                     runAtWeekends: Bool = false) -> Self {
        .init(rate: rate,
              startTime: startTime,
              endTime: endTime,
              runAtWeekends: runAtWeekends)
    }
}

public extension MeterSettings.MeterTime {

    static func fake(hour: Int,
                     minute: Int) -> Self {
        .init(hour: hour, minute: minute)
    }
    
}
