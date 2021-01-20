import Foundation
@testable import EarningsMeter

extension MeterSettings {

    static func day_worker_0900_to_1700(withDailyRate dailyRate: Double,
                                        runAtWeekends: Bool = false) -> MeterSettings {
        
        return .fake(rate: .init(amount: dailyRate, type: .daily),
                     startTime: .init(hour: 9, minute: 0),
                     endTime: .init(hour: 17, minute: 0),
                     runAtWeekends: runAtWeekends)
    }
    
    static func overnight_worker_2200_to_0600(withDailyRate dailyRate: Double,
                                              runAtWeekends: Bool = false) -> MeterSettings {
        
        return .fake(rate: .init(amount: dailyRate, type: .daily),
                     startTime: .init(hour: 22, minute: 0),
                     endTime: .init(hour: 6, minute: 0),
                     runAtWeekends: runAtWeekends)
    }
}


extension DateFormatter {
    
    static let testShortTimeStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
