import Foundation
import DataSources
import Model
import ViewComponents

public struct MeterViewState {
    
    // MARK: - Properties
    
    public let timeFormatter: DateComponentsFormatter
    public let settings: MeterSettings
    public let reading: MeterCalculator.Reading
    
    public var isEnabled: Bool {
        reading.progress > 0
    }
    
    public var startTimeText: String {
        timeFormatter.string(from: settings.startTime.asDateComponents()) ?? ""
    }
    
    public var endTimeText: String {
        timeFormatter.string(from: settings.endTime.asDateComponents()) ?? ""
    }
    
    public var hireStatus: MeterHireStatusView.Status {
        reading.hireStatus
    }
    
    // MARK: - Init
    
    public init(settings: MeterSettings,
                reading: MeterCalculator.Reading,
                timeFormatter: DateComponentsFormatter = defaultTimeFormatter) {
        self.settings = settings
        self.reading = reading
        self.timeFormatter = timeFormatter
    }
    
    public static let defaultTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        return formatter
    }()

}

private extension MeterCalculator.Reading {
    
    var hireStatus: MeterHireStatusView.Status {
        switch status {
        case .beforeWork, .afterWork, .dayOff:
            return .free
        case .atWork:
            return .atWork(progressValue: progress)
        }
    }
}
