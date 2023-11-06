import Foundation
import Models

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
