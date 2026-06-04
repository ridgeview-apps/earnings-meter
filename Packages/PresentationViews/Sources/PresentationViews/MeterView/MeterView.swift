import Models
import SwiftUI

public struct MeterView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.calendar) var calendar
    
    public enum Style: Int, Codable, CaseIterable, Sendable {
        case today, accumulated
    }

    // MARK: - Properties
    
    public let style: Style
    public let settings: MeterSettings
    public let reading: MeterReading
    
    @Binding public var selectedDate: Date

    private var isEnabled: Bool { reading.progress > 0 }
    private var showsDatePicker: Bool { style == .accumulated }
    private var hasCompactWidth: Bool { horizontalSizeClass == .compact }
    private var meterSpacing: CGFloat { hasCompactWidth ? 16 : 20 }
    private var meterPadding: CGFloat { hasCompactWidth ? 20 : 24 }
    private var progressBarHorizontalPadding: CGFloat { hasCompactWidth ? 8 : 16 }
    private var presentationState: MeterPresentationState {
        switch reading.status {
        case .notStarted:
            .inactive
        case .working:
            .active
        case .finished:
            .completed
        }
    }
    private var formattedSelectedDate: String {
        selectedDate.formatted(date: .abbreviated, time: .omitted)
    }
    
    // MARK: - Initializers
    
    public init(style: Style,
                settings: MeterSettings,
                reading: MeterReading,
                selectedDate: Binding<Date>) {
        self.style = style
        self.settings = settings
        self.reading = reading
        self._selectedDate = selectedDate
    }
    
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 24) {
            meterView
            datePickerContainerView
        }
        .frame(maxWidth: 450)
        .animation(.default, value: showsDatePicker)
    }
    
    
    // MARK: - Layout views
    
    public var meterView: some View {
        VStack(spacing: meterSpacing) {
            meterHeader
            VStack(spacing: 4) {
                digitsView
                hireStatusView
            }
            progressBarView
        }
        .padding(meterPadding)
        .meterCardStyle(presentationState)
    }
    
    private var meterHeader: some View {
        Group {
            switch style {
            case .today:
                Text(.meterHeaderEarningsTodayTitle)
            case .accumulated:
                Text(.meterHeaderEarningsSinceTitle(formattedSelectedDate))
            }
        }
        .instrumentLabel(.headline)
        .shrinkableSingleLine()
        .padding(.horizontal, 20)
        .foregroundColor(presentationState.headerColor)
    }
    
    private var digitsView: some View {
        MeterDigitsView(reading: reading,
                        style: hasCompactWidth ? .medium : .large)
        .animation(.snappy, value: reading.amountEarned)
    }
    
    private var progressBarView: some View {
        MeterProgressBarView(
            settings: settings, 
            reading: reading,
            showsTextLabels: true,
            calendar: calendar
        )
        .frame(maxWidth: 450)
        .padding(.horizontal, progressBarHorizontalPadding)
    }
    
    private var hireStatusView: some View {
        MeterHireStatusView(
            reading: reading,
            showEmoji: settings.emojisEnabled
        )
        .font(.subheadline)
    }
    
    @ViewBuilder private var datePickerContainerView: some View {
        if showsDatePicker {
            MeterAccumulatedDatePickerView(selectedDate: $selectedDate)
        }
    }
}


// MARK: - Previews

import ModelStubs

private struct WrapperView: View {
    let style: MeterView.Style
    var reading: MeterReading = .working(amountEarned: 123.45, progress: 0.5)

    @State var selectedDate: Date = .now
    
    var body: some View {
        NavigationStack {
            MeterView(style: style,
                      settings: ModelStubs.dayTime_0900_to_1700(),
                      reading: reading,
                      selectedDate: $selectedDate)
            .padding(.horizontal)
            .styledPreview()
            .navigationTitle("Preview")
        }
    }
}

#Preview("Today - before work") {
    WrapperView(style: .today, reading: .notStarted)
}

#Preview("Today - at work") {
    WrapperView(style: .today, reading: .working(amountEarned: 200, progress: 0.5))
}

#Preview("Today - after work") {
    WrapperView(style: .today, reading: .finished(amountEarned: 400))
}

#Preview("Accumulated earnings") {
    WrapperView(style: .accumulated,
                reading: .accumulated(amountEarned: 1234567, status: .working(progress: 0.5)))
}

#Preview("English / USD") {
    WrapperView(style: .today, reading: .working(amountEarned: 123.45, progress: 0.5))
        .environment(\.locale, Locale(identifier: "en_US"))
}

#Preview("Français / EUR") {
    WrapperView(style: .today, reading: .working(amountEarned: 123.45, progress: 0.5))
        .environment(\.locale, Locale(identifier: "fr_FR"))
}

#Preview("Español / EUR") {
    WrapperView(style: .today, reading: .working(amountEarned: 123.45, progress: 0.5))
        .environment(\.locale, Locale(identifier: "es_ES"))
}
