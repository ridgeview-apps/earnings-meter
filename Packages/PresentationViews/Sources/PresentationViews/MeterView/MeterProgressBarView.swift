import Models
import SwiftUI

public struct MeterProgressBarView: View {
    
    // MARK: - Properties
    
    public let leftLabelText: String
    public let rightLabelText: String
    public let value: Double
    public let showTextLabels: Bool
    public let isEnabled: Bool
    
    private let disabledFillColor = Color.redTwo
    
    public var body: some View {
        
        Gauge(value: value) {
            Text("")
        } currentValueLabel: {
            Text("")
        } minimumValueLabel: {
            Text(showTextLabels ? leftLabelText : "")
        } maximumValueLabel: {
            Text(showTextLabels ? rightLabelText : "")
        }
        .font(.subheadline)
        .foregroundColor(isEnabled ? .white : disabledFillColor)
        .tint(isEnabled ? .redOne : disabledFillColor)
        .gaugeStyle(.accessoryLinearCapacity)
        .frame(maxHeight: 20)
    }
}


// MARK: - Init

public extension MeterProgressBarView {
    
    init(settings: MeterSettings,
         reading: MeterCalculator.Reading,
         showsTextLabels: Bool,
         calendar: Calendar) {
        self.init(
            leftLabelText: settings.formattedStartTime(in: calendar),
            rightLabelText: settings.formattedEndTime(in: calendar),
            value: reading.progress,
            showTextLabels: showsTextLabels,
            isEnabled: reading.progress > 0
        )
    }
}

private extension MeterSettings {
    func formattedStartTime(forDate date: Date = .now, in calendar: Calendar) -> String {
        formattedText(forDate: date, withTime: startTime, in: calendar)
    }
    
    func formattedEndTime(iforDate date: Date = .now, in calendar: Calendar) -> String {
        formattedText(forDate: date, withTime: endTime, in: calendar)
    }
    
    private func formattedText(forDate date: Date,
                               withTime time: MeterSettings.MeterTime,
                               in calendar: Calendar) -> String {
        time
            .toMeterDateTime(for: date, in: calendar)
            .formatted(date: .omitted, time: .shortened)
    }
}


// MARK: - Previews

private func nineToFiveView(
   withProgress progressValue: Double,
   isEnabled: Bool = true,
   showTextLabels: Bool = true
) -> MeterProgressBarView {
   .init(
       leftLabelText: "09:00",
       rightLabelText: "17:00",
       value: progressValue,
       showTextLabels: showTextLabels,
       isEnabled: isEnabled
   )
}

#if DEBUG
#Preview {
    VStack {
        nineToFiveView(withProgress: 0.01)
        nineToFiveView(withProgress: 0.24)
        nineToFiveView(withProgress: 0.49)
        nineToFiveView(withProgress: 0.74)
        nineToFiveView(withProgress: 1)
        nineToFiveView(withProgress: 0, isEnabled: false)
        nineToFiveView(withProgress: 1, isEnabled: false)
        nineToFiveView(withProgress: 0.74, showTextLabels: false)
    }
    .background(Color.darkGrey1)
}
#endif
