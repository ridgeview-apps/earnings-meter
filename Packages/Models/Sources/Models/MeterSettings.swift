import Foundation
import RidgeviewCore

public struct MeterSettings: Codable, Equatable {
    public let rate: Rate
    public let startTime: MeterTime
    public let endTime: MeterTime
    public let runAtWeekends: Bool
    
    public init(rate: Rate,
                startTime: MeterTime,
                endTime: MeterTime,
                runAtWeekends: Bool) {
        self.rate = rate
        self.startTime = startTime
        self.endTime = endTime
        self.runAtWeekends = runAtWeekends
    }
}

public extension MeterSettings {
    
    struct Rate: Codable, Equatable {
        public enum RateType: Int, Codable, CaseIterable, Identifiable {
            case annual, daily, hourly
            
            public var id: RateType { self }
        }
        public let amount: Double
        public let type: RateType
        
        public init(amount: Double,
                    type: RateType) {
            self.amount = amount
            self.type = type
        }
    }
}

public extension MeterSettings {
    
    struct MeterTime: Equatable, Codable {
        
        public let hour: Int
        public let minute: Int
        
        public init(hour: Int,
                    minute: Int) {
            self.hour = hour
            self.minute = minute
        }
        
        public var seconds: TimeInterval {
            return TimeInterval((hour * 60 * 60) + (minute * 60))
        }
    }
}

public extension MeterSettings.MeterTime {
    
    func toMeterDateTime(for sourceDate: Date = .now, in calendar: Calendar) -> Date {
        guard let dateWithMeterTime = calendar.date(bySettingHour: hour,
                                                    minute: minute,
                                                    second: 0,
                                                    of: sourceDate) else {
            assertionFailure("Failed to derive date value from invalid meter time: \(self)")
            return .now
        }
        return dateWithMeterTime
    }
}
