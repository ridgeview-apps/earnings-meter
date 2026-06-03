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
        HStack(spacing: 10) {
            if showTextLabels {
                sideLabel(leftLabelText)
            }
            meterTrack
            if showTextLabels {
                sideLabel(rightLabelText)
            }
        }
        .frame(maxHeight: 20)
    }

    private func sideLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(.footnote, design: .monospaced, weight: .medium))
            .foregroundStyle(isEnabled ? Color.white : disabledFillColor)
    }

    private var meterTrack: some View {
        GeometryReader { proxy in
            let trackShape = Capsule()
            ZStack(alignment: .leading) {
                trackShape
                    .fill(
                        Color.black.opacity(0.45)
                            .shadow(.inner(color: .black.opacity(0.6), radius: 2, x: 0, y: 1))
                    )

                if value > 0 {
                    trackShape
                        .fill(
                            LinearGradient(
                                colors: isEnabled
                                    ? [Color.redOne.opacity(0.7), Color.redOne]
                                    : [disabledFillColor.opacity(0.7), disabledFillColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: proxy.size.width * value)
                        .shadow(color: isEnabled ? Color.redOne.opacity(0.5) : .clear, radius: 3)
                }

                HStack(spacing: 0) {
                    ForEach(0..<5) { index in
                        if index > 0 { Spacer(minLength: 0) }
                        Rectangle()
                            .fill(Color.white.opacity(0.22))
                            .frame(width: 1)
                    }
                }
                .padding(.horizontal, 4)
                .allowsHitTesting(false)
            }
            .clipShape(trackShape)
        }
        .frame(height: 10)
    }
}


// MARK: - Init

public extension MeterProgressBarView {
    
    init(settings: MeterSettings,
         reading: MeterReading,
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
