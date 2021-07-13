struct MeterSettings: Codable, Equatable {
    let rate: Rate
    let startTime: MeterTime
    let endTime: MeterTime
    let runAtWeekends: Bool
    
    var dailyRate: Double {
        switch rate.type {
        case .daily:
            return rate.amount
        case .hourly:
            let hoursWorked = workDayDuration / (60 * 60)
            return hoursWorked * rate.amount
        case .annual:
            // N.B. Deliberately an approximate calculation that doesn't support leap years.
            let workingDays = runAtWeekends ? 365.0 : 261.0
            return rate.amount / workingDays
        }
    }
}

extension MeterSettings {
    
    struct Rate: Codable, Equatable {
        enum RateType: Int, Codable, CaseIterable, Identifiable {
            case annual, daily, hourly
            
            var id: RateType { self }
        }
        let amount: Double
        let type: RateType
    }
}
