import Foundation
import RidgeviewCore

public struct MeterSettings: Codable, Equatable, Sendable {
    public let rate: Rate
    public let startTime: MeterTime
    public let endTime: MeterTime
    public let runAtWeekends: Bool
    public let emojisEnabled: Bool
    
    public init(rate: Rate,
                startTime: MeterTime,
                endTime: MeterTime,
                runAtWeekends: Bool,
                emojisEnabled: Bool) {
        self.rate = rate
        self.startTime = startTime
        self.endTime = endTime
        self.runAtWeekends = runAtWeekends
        self.emojisEnabled = emojisEnabled
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rate = try container.decode(MeterSettings.Rate.self, forKey: .rate)
        self.startTime = try container.decode(MeterSettings.MeterTime.self, forKey: .startTime)
        self.endTime = try container.decode(MeterSettings.MeterTime.self, forKey: .endTime)
        self.runAtWeekends = try container.decode(Bool.self, forKey: .runAtWeekends)
        do {
            self.emojisEnabled = try container.decode(Bool.self, forKey: .emojisEnabled)
        } catch {
            self.emojisEnabled = true
        }
    }
}

public extension MeterSettings {
    
    struct Rate: Codable, Equatable, Sendable {
        public enum RateType: Int, Codable, CaseIterable, Identifiable, Sendable {
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
    
    struct MeterTime: Equatable, Codable, Sendable {
        
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
