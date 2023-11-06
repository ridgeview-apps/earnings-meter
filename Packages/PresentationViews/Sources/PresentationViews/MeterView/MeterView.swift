import Models
import SwiftUI


public struct MeterView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.calendar) var calendar
    
    public enum Style: Int, Codable, CaseIterable {
        case today, accumulated
    }
    
    // MARK: - Properties
    
    public let style: Style
    public let settings: MeterSettings
    public let reading: MeterCalculator.Reading
    
    @Binding public var selectedDate: Date
    
    private var isEnabled: Bool { reading.progress > 0 }
    private var showsDatePicker: Bool { style == .accumulated }
    private var isTodaySelected: Bool { calendar.isDateInToday(selectedDate) }
    private var hasCompactWidth: Bool { horizontalSizeClass == .compact }
    private var today: Date { calendar.startOfDay(for: .now)}
    
    // MARK: - Initializers
    
    public init(style: Style,
                settings: MeterSettings,
                reading: MeterCalculator.Reading,
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
        .background(Color.darkGrey1)
        .roundedBorder(.white, cornerRadius: 16, lineWidth: 4)
        .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
        
    }
    
    private var meterHeader: some View {
        Group {
            switch style {
            case .today:
                Text("meter.header.earnings.today.title", bundle: .module)
            case .accumulated:
                Text("meter.header.earnings.since.title \(selectedDate.formatted(date: .abbreviated, time: .omitted))", bundle: .module)
            }
        }
        .textCase(.uppercase)
        .font(.title2)
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
        MeterHireStatusView(reading: reading, showLiveStatusImage: true)
            .font(.subheadline)
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
            Text("meter.date.picker.please.select", bundle: .module)
        }
    }
    
    private var dateResetButton: some View {
        Button {
            selectedDate = .now
        } label: {
            Text("Reset")
        }
        .disabled(isTodaySelected)
        .buttonStyle(.bordered)
        .tint(Color.redThree)
    }
}


// MARK: - Previews

private struct WrapperView: View {
    let style: MeterView.Style
    var amount: Double = 123.45
    var hireStatus: MeterCalculator.Reading.Status = .atWork(progress: 0.5)

    @State var selectedDate: Date = .now
    
    var body: some View {
        NavigationStack {
            MeterView(style: style,
                      settings: ModelStubs.dayTime_0900_to_1700(),
                      reading: .init(amountEarned: amount,
                                     status: hireStatus),
                      selectedDate: $selectedDate)
            .padding(.horizontal)
            .styledPreview()
            .navigationTitle("Preview")
        }
    }
}

#Preview("Today - before work") {
    WrapperView(style: .today, hireStatus: .beforeWork)
}

#Preview("Today - at work") {
    WrapperView(style: .today, hireStatus: .atWork(progress: 0.5))
}

#Preview("Today - after work") {
    WrapperView(style: .today, hireStatus: .afterWork)
}

#Preview("Accumulated earnings") {
    WrapperView(style: .accumulated)
}
