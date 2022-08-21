import Foundation
import Model
import RidgeviewCore

public struct MeterCalculator {
        
    // MARK: - Data types
    
    public struct Reading: Equatable {
        
        public enum Status {
            case dayOff
            case beforeWork
            case atWork
            case afterWork
        }
        
        public let amountEarned: Double
        public let progress: Double
        public let status: Status
        
        public init(amountEarned: Double,
                    progress: Double,
                    status: Status) {
            self.amountEarned = amountEarned
            self.progress = progress
            self.status = status
        }
        
        
        public static func zero(withStatus status: Status) -> Reading {
            .init(amountEarned: 0, progress: 0, status: status)
        }
    }
    

    // MARK: - Properties
    
    public let meterSettings: MeterSettings
    public let calendar: Calendar
    
    private let midday: TimeInterval = 12 * 60 * 60
    private let twentyFourHours: TimeInterval = 24 * 60 * 60
    
    public init(meterSettings: MeterSettings,
                calendar: Calendar = .current) {
        self.meterSettings = meterSettings
        self.calendar = calendar
    }
        
    public func calculateReading(at date: Date) -> MeterCalculator.Reading {
        let startTimeToday = meterSettings.startTime.asLocalTimeToday(now: date, calendar: calendar)
        let isWeekend = calendar.isDateInWeekend(startTimeToday)
        
        let isAWorkingDay = !isWeekend || (isWeekend && meterSettings.runAtWeekends)
        guard isAWorkingDay else {
            return .zero(withStatus: .dayOff)
        }
        
        return meterSettings.isOvernightWorker ? nightWorkerReading(at: date) : dayWorkerReading(at: date)
    }
    
    private func dayWorkerReading(at date: Date) -> MeterCalculator.Reading {
        let startTime = meterSettings.startTime.seconds
        let endTime = meterSettings.endTime.seconds
        
        let secondsElapsedToday = calendar.secondsElapsedSinceStartOfDay(until: date)

        if (startTime...endTime).contains(secondsElapsedToday) {
            let duration = endTime - startTime
            let amountWorked = secondsElapsedToday - startTime
            let progress = amountWorked / duration
            let amountEarned = progress * meterSettings.dailyRate
            return .init(amountEarned: amountEarned, progress: progress, status: .atWork)
        } else {
            return secondsElapsedToday < startTime
                ? .zero(withStatus: .beforeWork)
                : .init(amountEarned: meterSettings.dailyRate, progress: 1, status: .afterWork)
        }
    }
    
    private func nightWorkerReading(at date: Date) -> MeterCalculator.Reading {
        let startTime = meterSettings.startTime.seconds
        let endTime = meterSettings.endTime.seconds
        
        let secondsElapsedToday = calendar.secondsElapsedSinceStartOfDay(until: date)
        
        if secondsElapsedToday > startTime || secondsElapsedToday < endTime {
            let duration = (24.hours - startTime) + endTime
            let amountWorked: Double
            if secondsElapsedToday > startTime {
                amountWorked = secondsElapsedToday - startTime
            } else {
                amountWorked = (twentyFourHours - startTime) + secondsElapsedToday
            }
            let progress = amountWorked / duration
            let amountEarned = progress * meterSettings.dailyRate
            return .init(amountEarned: amountEarned, progress: progress, status: .atWork)
        } else {
            let meterResetTime: TimeInterval
                
            if endTime < midday {
                meterResetTime = midday
            } else {
                meterResetTime = endTime + ((startTime - endTime) / 2)
            }
            
            return secondsElapsedToday < meterResetTime
                ? .init(amountEarned: meterSettings.dailyRate, progress: 1, status: .afterWork)
                : .zero(withStatus: .beforeWork)
        }
    }

}

public extension MeterSettings {
    
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
    
    var defaultMeterSpeed: TimeInterval {
        // Default meter speed will try to increment the meter by 1 "unit" per second (e.g. 1 pence, cent etc per second)
        // Min meter speed is 0.3 to prevent the meter ticking too quickly (e.g. an insanely high earner!)
        let minMeterSpeed: TimeInterval = 0.3
        var desiredSpeed: TimeInterval = 1
        if dailyRate > 0 {
            desiredSpeed = workDayDuration / (dailyRate * 100)
        }
        return max(minMeterSpeed, desiredSpeed)
    }
}


private extension Calendar {
    func secondsElapsedSinceStartOfDay(until date: Date) -> TimeInterval {
        return date.timeIntervalSince1970 - startOfDay(for: date).timeIntervalSince1970
    }
}
