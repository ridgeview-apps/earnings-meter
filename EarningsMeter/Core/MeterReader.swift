import Foundation
import Combine

enum MeterReaderStatus: CaseIterable, Equatable {
    case free
    case atWork
}

final class MeterReader: ObservableObject {
    
    @Published private(set) var currentReading: Reading
    
    private var cancelBag = Set<AnyCancellable>()
    
    struct Reading: Equatable {
        
        let amountEarned: Double
        let progress: Double
        let status: MeterReaderStatus
        
        static func free(amountEarned: Double, progress: Double) -> Reading {
            Reading(amountEarned: amountEarned, progress: progress, status: .free)
        }
        
        static func atWork(amountEarned: Double, progress: Double) -> Reading {
            Reading(amountEarned: amountEarned, progress: progress, status: .atWork)
        }
    }
    
    init(environment: AppEnvironment,
         meterSettings: MeterSettings,         
         makeMeterTimer: (() -> Timer.TimerPublisher)? = nil) {
        
        let defaultTimer: () -> Timer.TimerPublisher = {
            return Timer.publish(every: meterSettings.defaultMeterSpeed, tolerance: 0.5, on: .main, in: .default)
        }
        
        let meterTimer = makeMeterTimer ?? defaultTimer
        
        currentReading = Self.calculateReadingNow(for: meterSettings, in: environment)
        
        let timer = onStart
            .map { _ in
                meterTimer().autoconnect()
            }
            .share()
        
        onStop
            .withLatestFrom(timer)
            .sink { timer in
                timer.upstream.connect().cancel()
            }
            .store(in: &cancelBag)
        
        timer
            .switchToLatest()
            .map { _ in
                Self.calculateReadingNow(for: meterSettings, in: environment)
            }
            .assign(to: \.currentReading, on: self, ownership: .weak)
            .store(in: &cancelBag)
    }
    
    // Mark: - Public API
    private let onStart = PassthroughSubject<Void, Never>()
    func start() {
        onStart.send()
    }
    
    private let onStop = PassthroughSubject<Void, Never>()
    func stop() {
        onStop.send()
    }
    
    private static func calculateReadingNow(for meterSettings: MeterSettings,
                                            in environment: AppEnvironment) -> Reading {
        let calculator = ReadingCalculator(meterSettings: meterSettings,
                                           environment: environment)
        return calculator.read()
    }
}

private extension MeterSettings {
    var isOvernightWorker: Bool {
        return endTime.seconds < startTime.seconds
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

// MARK: - Reading calculator
private struct ReadingCalculator {
    
    let meterSettings: MeterSettings
    let environment: AppEnvironment
    
    var secondsElapsedToday: TimeInterval {
        environment.currentCalendar().secondsElapsedToday(for: environment.date())
    }
    
    private let midday: TimeInterval = 12 * 60 * 60
    private let twentyFourHours: TimeInterval = 24 * 60 * 60
    
    func read() -> MeterReader.Reading {
        let startTimeToday = meterSettings.startTime.asLocalTimeToday(environment: environment)
        let calendar = environment.currentCalendar()
        let isWeekend = calendar.isDateInWeekend(startTimeToday)
        
        let isAWorkingDay = !isWeekend || (isWeekend && meterSettings.runAtWeekends)
        guard isAWorkingDay else {
            return .free(amountEarned: 0, progress: 0)
        }
        
        return meterSettings.isOvernightWorker ? nightWorkerReading : dayWorkerReading
    }
    
    private var dayWorkerReading: MeterReader.Reading {
        let startTime = meterSettings.startTime.seconds
        let endTime = meterSettings.endTime.seconds

        if (startTime...endTime).contains(secondsElapsedToday) {
            let duration = endTime - startTime
            let amountWorked = secondsElapsedToday - startTime
            let progress = amountWorked / duration
            let amountEarned = progress * meterSettings.dailyRate
            return .atWork(amountEarned: amountEarned, progress: progress)
        } else {
            return secondsElapsedToday < startTime
                ? .free(amountEarned: 0, progress: 0)
                : .free(amountEarned: meterSettings.dailyRate, progress: 1)
        }
    }
    
    private var nightWorkerReading: MeterReader.Reading {
        let startTime = meterSettings.startTime.seconds
        let endTime = meterSettings.endTime.seconds
        
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
            return .atWork(amountEarned: amountEarned, progress: progress)
        } else {
            let meterResetTime: TimeInterval
                
            if endTime < midday {
                meterResetTime = midday
            } else {
                meterResetTime = endTime + ((startTime - endTime) / 2)
            }
            
            return secondsElapsedToday < meterResetTime
                ? .free(amountEarned: meterSettings.dailyRate, progress: 1)
                : .free(amountEarned: 0, progress: 0)
        }
    }
}

private extension Calendar {
    func secondsElapsedToday(for date: Date) -> TimeInterval {
        return date.timeIntervalSince1970 - startOfDay(for: date).timeIntervalSince1970
    }
}
