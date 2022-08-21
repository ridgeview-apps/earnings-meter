import Combine
import DataSources
import Model
import SwiftUI
import ViewComponents

final class MeterHomeViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var currentReading: MeterCalculator.Reading = .zero(withStatus: .dayOff)
    
    let meterSettings: MeterSettings
    let calendar: Calendar
    let now: () -> Date
    
    private let autoconnectedTimer: Publishers.Autoconnect<Timer.TimerPublisher>    
    private let meterCalculator: MeterCalculator
    
    
    // MARK: - Init
    
    init(meterSettings: MeterSettings,
         calendar: Calendar = .current,
         now: @escaping () -> Date = { Date() }) {
        self.meterSettings = meterSettings
        self.now = now
        self.calendar = calendar
        
        self.meterCalculator = .init(meterSettings: meterSettings)
        self.autoconnectedTimer = Timer.publish(every: meterSettings.defaultMeterSpeed,
                                                tolerance: 0.5,
                                                on: .main,
                                                in: .default).autoconnect()

    }
    
    
    // MARK: - Start / stop timer
    
    func startMeterTimer() {
        let initialValue = meterCalculator.calculateReading(at: now())
        
        autoconnectedTimer
            .compactMap { [weak self] _ in
                guard let self = self else { return nil }
                return self.meterCalculator.calculateReading(at: self.now())
            }
            .prepend(initialValue)
            .removeDuplicates()
            .assign(to: &$currentReading)
    }
    
    func stopMeterTimer() {
        autoconnectedTimer.upstream.connect().cancel()
    }
}
