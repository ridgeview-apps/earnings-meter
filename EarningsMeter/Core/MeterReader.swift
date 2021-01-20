import Foundation
import Combine

final class MeterReader: ObservableObject {
    
    @Published private(set) var currentReading: Reading
    
    private var cancelBag = Set<AnyCancellable>()
    
    struct Reading: Equatable {
        
        enum Status {
            case offDuty
            case hired
        }
        
        let amountEarned: Double
        let progress: Double
        let status: Status
        
        static func offDuty(amountEarned: Double, progress: Double) -> Reading {
            Reading(amountEarned: amountEarned, progress: progress, status: .offDuty)
        }
        
        static func hired(amountEarned: Double, progress: Double) -> Reading {
            Reading(amountEarned: amountEarned, progress: progress, status: .hired)
        }
    }
    
    init(environment: AppEnvironment,
         meterSettings: MeterSettings,         
         makePublisher: @escaping () -> Timer.TimerPublisher = {
            Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .default)
        }) {
        
        currentReading = Self.calculateReadingNow(for: meterSettings, in: environment)
        
        let timer = onStart
            .map { _ in
                makePublisher().autoconnect()
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
    
    // MARK: - Reading calculation
    private static func calculateReadingNow(for meterSettings: MeterSettings,
                                            in environment: AppEnvironment) -> Reading {
        
        let startTimeToday = meterSettings.startTime.asLocalTimeToday(environment: environment)
        let calendar = environment.currentCalendar()
        let isWeekend = calendar.isDateInWeekend(startTimeToday)
        
        let isAWorkingDay = !isWeekend || (isWeekend && meterSettings.runAtWeekends)
        guard isAWorkingDay else {
            return .offDuty(amountEarned: 0, progress: 0)
        }
        
        let secondsElapsedToday = calendar.secondsElapsedToday(for: environment.date())
        
        let workingDayStatus = WorkingDayStatus(meterSettings: meterSettings,
                                                secondsElapsedToday: secondsElapsedToday)
        
        switch workingDayStatus.read() {
        case .beforeWork:
            return .offDuty(amountEarned: 0, progress: 0)
        case .afterWork:
            return .offDuty(amountEarned: meterSettings.dailyRate, progress: 1)
        case let .atWork(progress):
            let amountEarned = progress * meterSettings.dailyRate
            return .hired(amountEarned: amountEarned, progress: progress)
        }
    }
}

private extension MeterSettings {
    var isOvernightWorker: Bool {
        return endTime.seconds < startTime.seconds
    }
}

private struct WorkingDayStatus {
    
    enum Status {
        case beforeWork
        case atWork(progress: Double)
        case afterWork
    }
    
    var meterSettings: MeterSettings
    var secondsElapsedToday: TimeInterval
    
    private let midday: TimeInterval = 12 * 60 * 60
    private let twentyFourHours: TimeInterval = 24 * 60 * 60
    
    func read() -> Status {
        meterSettings.isOvernightWorker ? nightWorkerStatus : dayWorkerStatus
    }
    
    private var dayWorkerStatus: Status {
        let startTime = meterSettings.startTime.seconds
        let endTime = meterSettings.endTime.seconds

        if (startTime...endTime).contains(secondsElapsedToday) {
            let duration = endTime - startTime
            let amountWorked = secondsElapsedToday - startTime
            let progress = amountWorked / duration
            return .atWork(progress: progress)
        } else {
            return secondsElapsedToday < startTime ? .beforeWork : .afterWork
        }
    }
    
    private var nightWorkerStatus: Status {
        let startTime = meterSettings.startTime.seconds
        let endTime = meterSettings.endTime.seconds
        
        if secondsElapsedToday > startTime || secondsElapsedToday < endTime {
            let duration = (twentyFourHours - startTime) + endTime
            let amountWorked: Double
            if secondsElapsedToday > startTime {
                amountWorked = secondsElapsedToday - startTime
            } else {
                amountWorked = (twentyFourHours - startTime) + secondsElapsedToday
            }
            let progress = amountWorked / duration
            return .atWork(progress: progress)
        } else {
            let meterResetTime: TimeInterval
                
            if endTime < midday {
                meterResetTime = midday
            } else {
                meterResetTime = endTime + ((startTime - endTime) / 2)
            }
            
            return secondsElapsedToday < meterResetTime ? .afterWork : .beforeWork
        }
    }
}

private extension Calendar {
    func secondsElapsedToday(for date: Date) -> TimeInterval {
        return date.timeIntervalSince1970 - startOfDay(for: date).timeIntervalSince1970
    }
}