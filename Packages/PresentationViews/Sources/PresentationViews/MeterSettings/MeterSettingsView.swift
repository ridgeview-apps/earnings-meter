import Foundation
import Models
import SwiftUI

public struct MeterSettingsView: View {
    
    @Binding var inputForm: MeterSettingsInputForm
    
    @FocusState private var isRateTextFieldFocused: Bool
    
    @State private var isStartTimeExpanded = false
    @State private var isEndTimeExpanded = false
    @State private var showDebugSection = false
    
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
                                     selectedTime: $inputForm.startTime,
                                     isExpanded: $isStartTimeExpanded)
                ExpandableTimePicker(title: .settingsWorkingHoursEndTimeTitle,
                                     selectedTime: $inputForm.endTime,
                                     isExpanded: $isEndTimeExpanded)
                runAtWeekendsToggle
                emojisEnabledToggle
            }
        }
        .scrollDismissesKeyboard(.interactively)
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
            ratePicker
        }
        .animation(.default, value: inputForm.rateType)
    }
    
    @ViewBuilder private var calculatedDailyRateInfo: some View {
        switch inputForm.rateType {
        case .annual where !calculatedDailyRateText.isEmpty:
            calculatedDailyRateInfo(.settingsRateCalculated(calculatedDailyRateText))
        case .hourly where !calculatedDailyRateText.isEmpty:
            calculatedDailyRateInfo(.settingsRateCalculatedExact(calculatedDailyRateText))
        default:
            EmptyView()
        }
    }
    
    private var calculatedDailyRateText: String {
        inputForm.dailyRate?.currencyFormatted(forLocale: locale) ?? ""
    }
    
    @ViewBuilder private func calculatedDailyRateInfo(_ message: LocalizedStringResource) -> some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.redThree)
            Text(message)
                .font(.headline)
                .foregroundColor(.redThree)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
            Spacer()
        }
        .padding(8)
        .roundedBorder(Color.redThree, lineWidth: 2)
    }
    
    private var rateTextField: some View {
        HStack {
            Text(.settingsRateTitle)
            Text(locale.currencySymbol ?? "$")
            TextField(text: $inputForm.rateAmountFieldText) {
                Text(.settingsRatePlaceholder)
            }
            .accessibilityIdentifier("acc.id.rate.textfield")
            .textFieldStyle(.roundedBorder)
            .keyboardType(.decimalPad)
            .focused($isRateTextFieldFocused)            
            .showsClearButtonWhileEditing($inputForm.rateAmountFieldText)
        }
        .onTapGesture {
            isRateTextFieldFocused = true
        }
    }
    
    private var ratePicker: some View {
        Picker("", selection: $inputForm.rateType) {
            ForEach(MeterSettings.Rate.RateType.allCases) { rateType in
                Text(rateType.localizedStringResource).tag(rateType)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var runAtWeekendsToggle: some View {
        Toggle(isOn: $inputForm.runAtWeekends) {
            Text(.settingsRunAtWeekendsTitle)
        }
        .toggleStyle(SwitchToggleStyle(tint: .redOne))
    }
    
    private var emojisEnabledToggle: some View {
        Toggle(isOn: $inputForm.emojisEnabled) {
            Text(.settingsEmojisEnabledTitle)
        }
        .toggleStyle(SwitchToggleStyle(tint: .redOne))
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
