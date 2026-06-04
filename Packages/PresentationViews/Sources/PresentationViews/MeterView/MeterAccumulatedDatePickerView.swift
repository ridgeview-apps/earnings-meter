import SwiftUI

struct MeterAccumulatedDatePickerView: View {

    @Environment(\.calendar) private var calendar

    @Binding var selectedDate: Date

    @State private var showResetConfirmation: Bool = false

    private var today: Date { calendar.startOfDay(for: .now) }
    private var isTodaySelected: Bool { calendar.isDateInToday(selectedDate) }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)

            datePicker
                .frame(maxWidth: .infinity, alignment: .leading)

            dateResetButton
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.secondary.opacity(0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.secondary.opacity(0.22), lineWidth: 1)
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private var datePicker: some View {
        DatePicker(
            selection: $selectedDate,
            in: ...today,
            displayedComponents: [.date]
        ) {
            Text(.meterDatePickerPleaseSelect)
        }
        .datePickerStyle(.compact)
    }

    private var dateResetButton: some View {
        Button {
            showResetConfirmation = true
        } label: {
            Text(.meterDatePickerResetButtonTitle)
                .font(.subheadline.weight(.semibold))
        }
        .disabled(isTodaySelected)
        .buttonStyle(.bordered)
        .tint(Color.redThree)
        .confirmationDialog(
            Text(.meterDatePickerResetConfirmTitle),
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                selectedDate = .now
            } label: {
                Text(.meterDatePickerResetButtonTitle)
            }
            Button(role: .cancel) {
            } label: {
                Text(.meterDatePickerResetConfirmCancelButton)
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedDate = Date.now

    MeterAccumulatedDatePickerView(selectedDate: $selectedDate)
        .padding()
        .styledPreview()
}
