import Foundation
import Models
import RidgeviewCore

public struct MeterCalculator {
    
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
        
    public func dailyReading(at date: Date) -> MeterReading {
        let startTimeToday = meterSettings.startTime.toMeterDateTime(for: date, in: calendar)
        let isWeekend = calendar.isDateInWeekend(startTimeToday)
        
        let isAWorkingDay = !isWeekend || (isWeekend && meterSettings.runAtWeekends)
        guard isAWorkingDay else {
            return .notStarted
        }
        
        return meterSettings.isOvernightWorker ? nightWorkerReading(at: date) : dayWorkerReading(at: date)
    }
    
    public func accumulatedReading(at now: Date,
                                   since sinceDate: Date) -> MeterReading {
        
        let pastEarningsStartDate = calendar.startOfDay(for: sinceDate)
        guard pastEarningsStartDate <= now else {
            assertionFailure("Invalid date range specified - cannot calculate an accumulated reading from \(sinceDate) until \(now)")
            return .notStarted
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
        let mergedReading = MeterReading.accumulated(
            amountEarned: accumulatedYearsAmount + accumulatedDaysAmount + currentDailyReading.amountEarned,
            status: currentDailyReading.status
        )
        
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
        
    private func dayWorkerReading(at date: Date) -> MeterReading {
        let startTime = meterSettings.startTime.seconds
        let endTime = meterSettings.endTime.seconds
        
        let secondsElapsedToday = calendar.secondsElapsedSinceStartOfDay(until: date)

        if (startTime...endTime).contains(secondsElapsedToday) {
            let duration = endTime - startTime
            let amountWorked = secondsElapsedToday - startTime
            let progress = amountWorked / duration
            let amountEarned = progress * meterSettings.dailyRate
            return .working(amountEarned: amountEarned, progress: progress)
        } else {
            return secondsElapsedToday < startTime
                ? .notStarted
                : .finished(amountEarned: meterSettings.dailyRate)
        }
    }
    
    private func nightWorkerReading(at date: Date) -> MeterReading {
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
            return .working(amountEarned: amountEarned, progress: progress)
        } else {
            let meterResetTime: TimeInterval
                
            if endTime < midday {
                meterResetTime = midday
            } else {
                meterResetTime = endTime + ((startTime - endTime) / 2)
            }
            
            return secondsElapsedToday < meterResetTime
                ? .finished(amountEarned: meterSettings.dailyRate)
                : .notStarted
        }
    }

}

private extension Calendar {
    func secondsElapsedSinceStartOfDay(until date: Date) -> TimeInterval {
        return date.timeIntervalSince1970 - startOfDay(for: date).timeIntervalSince1970
    }
}
