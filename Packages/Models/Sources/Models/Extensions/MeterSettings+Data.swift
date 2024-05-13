import Foundation

public extension MeterSettings {
    
    var dailyRate: Double {
        switch rate.type {
        case .daily:
            rate.amount
        case .hourly:
            hoursWorkedPerDay * rate.amount
        case .annual:
            rate.amount / businessDaysPerYear
        }
    }
    
    var annualRate: Double {
        switch rate.type {
        case .daily:
            rate.amount * businessDaysPerYear
        case .hourly:
            hoursWorkedPerDay * rate.amount * businessDaysPerYear
        case .annual:
            rate.amount
        }
    }
    
    var workDayDuration: TimeInterval {
        let duration: TimeInterval
        if isOvernightWorker {
            duration = (24.hours - startTime.seconds) + endTime.seconds
        } else {
            duration = endTime.seconds - startTime.seconds
        }
        return duration
    }
    
    var isOvernightWorker: Bool {
        return endTime.seconds < startTime.seconds
    }
}

private extension MeterSettings {
    var hoursWorkedPerDay: Double {
        workDayDuration / (60 * 60)
    }
    
    var businessDaysPerYear: Double {
        // N.B. APPROXIMATELY!!!
        // The app doesn't support public holidays or leap years (adds unnecessary complexity / not needed right now)
        runAtWeekends ? 365.0 : 261.0
    }
}
