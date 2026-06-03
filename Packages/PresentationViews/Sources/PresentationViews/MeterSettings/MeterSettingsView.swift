import Foundation
import Models
import SwiftUI

public struct MeterSettingsView: View {

    @Binding var inputForm: MeterSettingsInputForm

    @FocusState private var isRateTextFieldFocused: Bool

    @State private var isStartTimeExpanded = false
    @State private var isEndTimeExpanded = false

    @Environment(\.locale) var locale

    public init(inputForm: Binding<MeterSettingsInputForm>) {
        self._inputForm = inputForm
    }

    public var body: some View {
        List {
            Section(header: sectionHeader) {
                rateDetails
                    .padding([.top, .bottom], 12)
                ExpandableTimePicker(title: .settingsWorkingHoursStartTimeTitle,
                                     accessibilityIdentifier: "acc.id.start.time.disclosure",
                                     selectedTime: $inputForm.startTime,
                                     isExpanded: $isStartTimeExpanded)
                ExpandableTimePicker(title: .settingsWorkingHoursEndTimeTitle,
                                     accessibilityIdentifier: "acc.id.end.time.disclosure",
                                     selectedTime: $inputForm.endTime,
                                     isExpanded: $isEndTimeExpanded)
                workingHoursInfo
                runAtWeekendsToggle
                emojisEnabledToggle
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: isStartTimeExpanded) { _, isExpanded in
            if isExpanded {
                withAnimation {
                    isEndTimeExpanded = false
                }
            }
        }
        .onChange(of: isEndTimeExpanded) { _, isExpanded in
            if isExpanded {
                withAnimation {
                    isStartTimeExpanded = false
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    isRateTextFieldFocused = false
                } label: {
                    Text(.settingsKeyboardDone)
                }
            }
        }
    }

    @ViewBuilder private var sectionHeader: some View {
        if inputForm.editMode == .welcome {
            Text(.settingsWelcomeMessage)
        }
    }

    private var rateDetails: some View {
        VStack {
            calculatedDailyRateInfo
            rateTextField
            invalidRateAmountInfo
            ratePicker
        }
        .animation(.easeInOut(duration: 0.2), value: inputForm.rateType)
        .animation(.easeInOut(duration: 0.2), value: calculatedDailyRateText.isEmpty)
    }

    @ViewBuilder private var calculatedDailyRateInfo: some View {
        switch inputForm.rateType {
        case .annual where !calculatedDailyRateText.isEmpty:
            calculatedDailyRateInfo(.settingsRateCalculated(calculatedDailyRateText))
                .transition(.opacity.combined(with: .move(edge: .top)))
        case .hourly where !calculatedDailyRateText.isEmpty:
            calculatedDailyRateInfo(.settingsRateCalculatedExact(calculatedDailyRateText))
                .transition(.opacity.combined(with: .move(edge: .top)))
        default:
            EmptyView()
        }
    }

    private var calculatedDailyRateText: String {
        inputForm.dailyRate?.currencyFormatted(forLocale: locale) ?? ""
    }

    @ViewBuilder private func calculatedDailyRateInfo(_ message: LocalizedStringResource) -> some View {
        let infoColor = Color.accentColor
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.body.weight(.semibold))
                .foregroundColor(infoColor)
                .padding(.top, 1)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(infoColor.opacity(0.08))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(infoColor.opacity(0.2), lineWidth: 1)
        }
    }

    private var rateTextField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(.settingsRateTitle)
            HStack(spacing: 10) {
                Text(locale.currencySymbol ?? "$")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.secondary.opacity(0.12))
                    )
                TextField(text: $inputForm.rateAmountFieldText) {
                    Text(.settingsRatePlaceholder)
                }
                .accessibilityIdentifier("acc.id.rate.textfield")
                .keyboardType(.decimalPad)
                .focused($isRateTextFieldFocused)
                .onChange(of: inputForm.rateAmountFieldText) { _, updatedText in
                    normalizeRateDecimalSeparator(updatedText)
                }
                .showsClearButtonWhileEditing($inputForm.rateAmountFieldText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.secondary.opacity(0.06))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(rateTextFieldBorderColor, lineWidth: rateTextFieldBorderWidth)
            }
            .contentShape(Rectangle())
        }
        .onTapGesture {
            isRateTextFieldFocused = true
        }
        .animation(.easeInOut(duration: 0.15), value: isRateTextFieldFocused)
        .animation(.easeInOut(duration: 0.15), value: shouldShowRateValidationError)
    }

    @ViewBuilder private var invalidRateAmountInfo: some View {
        if shouldShowRateValidationError {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.redThree)
                Text(.settingsRateValidationInvalidAmount)
                    .font(.footnote)
                    .foregroundColor(.redThree)
                Spacer()
            }
            .accessibilityIdentifier("acc.id.rate.validation.error")
        }
    }

    private var ratePicker: some View {
        Picker("", selection: $inputForm.rateType) {
            ForEach(MeterSettings.Rate.RateType.allCases) { rateType in
                Text(rateType.localizedStringResource).tag(rateType)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel(Text(.settingsRatePickerAccessibilityLabel))
        .accessibilityHint(Text(.settingsRatePickerAccessibilityHint))
        .accessibilityIdentifier("acc.id.rate.type.picker")
    }

    private var runAtWeekendsToggle: some View {
        Toggle(isOn: $inputForm.runAtWeekends) {
            Text(.settingsRunAtWeekendsTitle)
        }
        .toggleStyle(SwitchToggleStyle(tint: .redOne))
        .accessibilityHint(Text(.settingsRunAtWeekendsAccessibilityHint))
        .accessibilityIdentifier("acc.id.run.at.weekends.toggle")
    }

    private var emojisEnabledToggle: some View {
        Toggle(isOn: $inputForm.emojisEnabled) {
            Text(.settingsEmojisEnabledTitle)
        }
        .toggleStyle(SwitchToggleStyle(tint: .redOne))
        .accessibilityHint(Text(.settingsEmojisEnabledAccessibilityHint))
        .accessibilityIdentifier("acc.id.emojis.enabled.toggle")
    }

    private var shouldShowRateValidationError: Bool {
        !inputForm.rateAmountFieldText.isEmpty && parsedRateAmount == nil
    }

    private var rateTextFieldBorderColor: Color {
        if shouldShowRateValidationError {
            return .redThree
        }
        return isRateTextFieldFocused ? .accentColor : Color.secondary.opacity(0.25)
    }

    private var rateTextFieldBorderWidth: CGFloat {
        (isRateTextFieldFocused || shouldShowRateValidationError) ? 1.5 : 1
    }

    private var parsedRateAmount: Double? {
        try? Double(inputForm.rateAmountFieldText, format: localeAwareRateAmountFormat)
    }

    private var localeAwareRateAmountFormat: FloatingPointFormatStyle<Double> {
        .number
            .locale(locale)
            .precision(.fractionLength(2))
    }

    private func normalizeRateDecimalSeparator(_ text: String) {
        guard let decimalSeparator = locale.decimalSeparator else { return }
        let alternateSeparator = decimalSeparator == "." ? "," : "."
        guard text.contains(alternateSeparator), !text.contains(decimalSeparator) else { return }
        inputForm.rateAmountFieldText = text.replacingOccurrences(of: alternateSeparator, with: decimalSeparator)
    }

    @ViewBuilder private var workingHoursInfo: some View {
        if !inputForm.hasValidWorkingHours {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.redThree)
                Text(.settingsWorkingHoursInvalid)
                    .font(.footnote)
                    .foregroundColor(.redThree)
                Spacer()
            }
            .accessibilityIdentifier("acc.id.working.hours.invalid")
        } else if inputForm.hasOvernightWorkingHours {
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .foregroundColor(.redThree)
                Text(.settingsWorkingHoursOvernightInfo)
                    .font(.footnote)
                    .foregroundColor(.redThree)
                Spacer()
            }
            .accessibilityIdentifier("acc.id.working.hours.overnight")
        }
    }
}

private extension MeterSettings.Rate.RateType {

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .daily: .settingsRatePickerDaily
        case .annual: .settingsRatePickerAnnual
        case .hourly: .settingsRatePickerHour
        }
    }

}


// MARK: - Previews
import ModelStubs

private struct WrapperView: View {
    @State var inputForm: MeterSettingsInputForm = .updateMode(with: ModelStubs.dayTime_0900_to_1700())

    var body: some View {
        MeterSettingsView(inputForm: $inputForm)
    }
}

#Preview("Welcome mode") {
    WrapperView(inputForm: .welcomeMode())
}

#Preview("Update mode") {
    WrapperView()
}
