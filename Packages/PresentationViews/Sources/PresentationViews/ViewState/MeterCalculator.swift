import Foundation
import Models
import RidgeviewCore

public struct MeterCalculator {
        
    // MARK: - Data types
    
    public struct Reading: Equatable {
        
        public enum Status: Equatable {
            case dayOff
            case beforeWork
            case atWork(progress: Double)
            case afterWork
        }
        
        public let amountEarned: Double
        public var progress: Double {
            switch status {
            case .dayOff, .beforeWork:
                return 0
            case .afterWork:
                return 1
            case .atWork(let progress):
                return progress
            }
        }
        public let status: Status
        
        public init(amountEarned: Double,
                    status: Status) {
            self.amountEarned = amountEarned
            self.status = status
        }
        
        
        public static func zero(withStatus status: Status) -> Reading {
            .init(amountEarned: 0.0, status: status)
        }
        
        public static let placeholder = Reading(amountEarned: 25, status: .atWork(progress: 0.25))
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
        
    public func dailyReading(at date: Date) -> Reading {
        let startTimeToday = meterSettings.startTime.toMeterDateTime(for: date, in: calendar)
        let isWeekend = calendar.isDateInWeekend(startTimeToday)
        
        let isAWorkingDay = !isWeekend || (isWeekend && meterSettings.runAtWeekends)
        guard isAWorkingDay else {
            return .zero(withStatus: .dayOff)
        }
        
        return meterSettings.isOvernightWorker ? nightWorkerReading(at: date) : dayWorkerReading(at: date)
    }
    
    public func accumulatedReading(at now: Date,
                                   since sinceDate: Date) -> Reading {
        
        let pastEarningsStartDate = calendar.startOfDay(for: sinceDate)
        guard pastEarningsStartDate <= now else {
            assertionFailure("Invalid date range specified - cannot calculate an accumulated reading from \(sinceDate) until \(now)")
            return .zero(withStatus: .beforeWork)
        }
        
        // 1. Get the current daily reading
        let currentDailyReading = dailyReading(at: now)
        
        // 2. Get the accumulated past earnings (years + days)
        var pastEarningsEndDate = calendar.startOfDay(for: now)
        if meterSettings.isOvernightWorker && calendar.secondsElapsedSinceStartOfDay(until: now) < midday {
            pastEarningsEndDate -= 12.hours
        }
        
        let dateDiff = calendar.dateComponents([.year, .day], from: pastEarningsStartDate, to: pastEarningsEndDate) // e.g. 1 Feb 2021 to 1 Aug 2023 => 2 years, 181  days
        let accumulatedYearsAmount = accumulatedEarnings(forYearsWorked: dateDiff.year)
        let accumulatedDaysAmount = accumulatedEarnings(forDaysWorked: dateDiff.day, before: pastEarningsEndDate)
                
        // 3. Merge past & current earnings together
        let mergedReading = Reading(amountEarned: accumulatedYearsAmount + accumulatedDaysAmount + currentDailyReading.amountEarned,
                                    status: currentDailyReading.status)
        
        return mergedReading
    }
    
    private func accumulatedEarnings(forYearsWorked years: Int?) -> Double {
        guard let years else { return 0 }
        return Double(years) * meterSettings.annualRate
    }
    
    private func accumulatedEarnings(forDaysWorked days: Int?, before endDate: Date) -> Double {
        guard let days, days > 0, let startDate = calendar.date(byAdding: .day, value: -1 * days, to: endDate) else {
            return 0
        }

        var workingDaysCount = 0
        var currentDate = startDate
        
        while currentDate < endDate {
            let isWeekend = calendar.isDateInWeekend(currentDate)
            let isAWorkingDay = !isWeekend || (isWeekend && meterSettings.runAtWeekends)
            if isAWorkingDay {
                workingDaysCount += 1
            }
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDay
        }
        
        return Double(workingDaysCount) * meterSettings.dailyRate
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
            return .init(amountEarned: amountEarned, status: .atWork(progress: progress))
        } else {
            return secondsElapsedToday < startTime
                ? .zero(withStatus: .beforeWork)
                : .init(amountEarned: meterSettings.dailyRate, status: .afterWork)
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
            return .init(amountEarned: amountEarned, status: .atWork(progress: progress))
        } else {
            let meterResetTime: TimeInterval
                
            if endTime < midday {
                meterResetTime = midday
            } else {
                meterResetTime = endTime + ((startTime - endTime) / 2)
            }
            
            return secondsElapsedToday < meterResetTime
                ? .init(amountEarned: meterSettings.dailyRate, status: .afterWork)
                : .zero(withStatus: .beforeWork)
        }
    }

}

public extension MeterSettings {
    
    static let placeholder = MeterSettings(rate: .init(amount: 100, type: .daily),
                                           startTime: .init(hour: 9, minute: 0),
                                           endTime: .init(hour: 5, minute: 0),
                                           runAtWeekends: true)
    
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
    
    var hoursWorkedPerDay: Double {
        workDayDuration / (60 * 60)
    }
    
    var businessDaysPerYear: Double {
        // N.B. APPROXIMATELY!!! 
        // The app doesn't support public holidays or leap years (adds unnecessary complexity / not needed right now)
        runAtWeekends ? 365.0 : 261.0
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
