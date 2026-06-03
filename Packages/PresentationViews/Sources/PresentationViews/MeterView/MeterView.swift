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
    private var isTodaySelected: Bool { calendar.isDateInToday(selectedDate) }
    private var hasCompactWidth: Bool { horizontalSizeClass == .compact }
    private var today: Date { calendar.startOfDay(for: .now)}
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
        VStack(spacing: 12) {
            meterHeader
            VStack(spacing: 4) {
                digitsView
                hireStatusView
            }
            progressBarView
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    Color.darkGrey1
                        .shadow(.inner(color: .black.opacity(0.55), radius: 6, x: 0, y: 4))
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 4
                )
        }
        .shadow(color: .black.opacity(0.22), radius: 6, x: 0, y: 3)
        
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
        .instrumentLabel()
        .shrinkableSingleLine()
        .padding(.horizontal, 20)
        .foregroundColor(.white)
    }
    
    private var digitsView: some View {
        MeterDigitsView(reading: reading,
                        style: hasCompactWidth ? .medium : .large)
        .animation(.default, value: reading.amountEarned)
    }
    
    private var progressBarView: some View {
        MeterProgressBarView(
            settings: settings, 
            reading: reading,
            showsTextLabels: true,
            calendar: calendar
        )
        .frame(maxWidth: 450)
    }
    
    private var hireStatusView: some View {
        MeterHireStatusView(
            reading: reading,
            showEmoji: settings.emojisEnabled
        )
        .font(.caption)
    }
    
    @ViewBuilder private var datePickerContainerView: some View {
        if showsDatePicker {
            HStack {
                datePicker
                dateResetButton
            }
        }
    }
    
    private var datePicker: some View {
        DatePicker(selection: $selectedDate,
                   in: ...today,
                   displayedComponents: [.date]) {
            Text(.meterDatePickerPleaseSelect)
        }
    }
    
    private var dateResetButton: some View {
        Button {
            selectedDate = .now
        } label: {
            Text(.meterDatePickerResetButtonTitle)
        }
        .disabled(isTodaySelected)
        .buttonStyle(.bordered)
        .tint(Color.redThree)
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
