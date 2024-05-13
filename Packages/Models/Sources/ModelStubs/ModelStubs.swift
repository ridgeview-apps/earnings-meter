import Foundation
import Models

public enum ModelStubs {} // Namespace

public extension ModelStubs {
    
    static func dayTime_0900_to_1700(rate: MeterSettings.Rate = .init(amount: 400, type: .daily),
                                     runAtWeekends: Bool = false) -> MeterSettings {
        meterSettings(rate: rate,
                      startTime: .init(hour: 9, minute: 0),
                      endTime: .init(hour: 17, minute: 0),
                      runAtWeekends: runAtWeekends)
    }
    
    static func nightTime_2200_to_0600(rate: MeterSettings.Rate = .init(amount: 400, type: .daily),
                                       runAtWeekends: Bool = false) -> MeterSettings {
        meterSettings(rate: rate,
                      startTime: .init(hour: 22, minute: 0),
                      endTime: .init(hour: 6, minute: 0),
                      runAtWeekends: runAtWeekends)
    }
    
    private static func meterSettings(rate: MeterSettings.Rate = .init(amount: 40_000, type: .annual),
                                      startTime: MeterSettings.MeterTime = .init(hour: 8, minute: 10),
                                      endTime: MeterSettings.MeterTime = .init(hour: 18, minute: 30),
                                      runAtWeekends: Bool = false) -> MeterSettings {
        .init(rate: rate,
              startTime: startTime,
              endTime: endTime,
              runAtWeekends: runAtWeekends)
    }
}
