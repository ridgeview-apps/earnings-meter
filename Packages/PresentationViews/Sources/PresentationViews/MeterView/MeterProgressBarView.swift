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
    private var clampedValue: Double { min(max(value, 0), 1) }
    private var hasProgress: Bool { clampedValue > 0 }

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
        .animation(.snappy, value: clampedValue)
    }

    private func sideLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(.footnote, design: .monospaced, weight: .medium))
            .foregroundStyle(isEnabled ? Color.white : disabledFillColor)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private var meterTrack: some View {
        GeometryReader { proxy in
            let trackShape = Capsule()
            ZStack(alignment: .leading) {
                trackBackground(trackShape)

                if hasProgress {
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
                        .frame(width: proxy.size.width * clampedValue)
                        .shadow(color: isEnabled ? Color.redOne.opacity(0.5) : .clear, radius: 3)
                }

                segmentMarks
            }
            .clipShape(trackShape)
            .overlay {
                trackShape
                    .strokeBorder(Color.white.opacity(hasProgress ? 0.18 : 0.24), lineWidth: 1)
            }
        }
        .frame(height: 10)
    }

    private func trackBackground(_ trackShape: Capsule) -> some View {
        trackShape
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(hasProgress ? 0.08 : 0.12),
                        Color.black.opacity(hasProgress ? 0.45 : 0.32)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .shadow(.inner(color: .black.opacity(hasProgress ? 0.6 : 0.35), radius: 2, x: 0, y: 1))
            )
    }

    private var segmentMarks: some View {
        GeometryReader { proxy in
            let inset: CGFloat = 4
            let availableWidth = max(proxy.size.width - inset * 2, 0)

            ForEach(1..<5) { index in
                Rectangle()
                    .fill(Color.white.opacity(hasProgress ? 0.22 : 0.14))
                    .frame(width: 1)
                    .position(
                        x: inset + availableWidth * CGFloat(index) / 5,
                        y: proxy.size.height / 2
                    )
            }
        }
        .allowsHitTesting(false)
    }
}


// MARK: - Init

public extension MeterProgressBarView {

    init(
        settings: MeterSettings,
        reading: MeterReading,
        showsTextLabels: Bool,
        calendar: Calendar
    ) {
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

    private func formattedText(
        forDate date: Date,
        withTime time: MeterSettings.MeterTime,
        in calendar: Calendar
    ) -> String {
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
