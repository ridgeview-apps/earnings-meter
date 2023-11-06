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
                ExpandableTimePicker(title: "settings.workingHours.startTime.title",
                                     selectedTime: $inputForm.startTime,
                                     isExpanded: $isStartTimeExpanded)
                ExpandableTimePicker(title: "settings.workingHours.endTime.title",
                                     selectedTime: $inputForm.endTime,
                                     isExpanded: $isEndTimeExpanded)
                runAtWeekendsToggle
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    @ViewBuilder private var sectionHeader: some View {
        if inputForm.editMode == .welcome {
            Text("settings.welcome.message", bundle: .module)
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
            calculatedDailyRateInfo {
                Text("settings.rate.calculated \(calculatedDailyRateText)", bundle: .module)
            }
        case .hourly where !calculatedDailyRateText.isEmpty:
            calculatedDailyRateInfo {
                Text("settings.rate.calculated.exact \(calculatedDailyRateText)", bundle: .module)
            }
        default:
            EmptyView()
        }
    }
    
    private var calculatedDailyRateText: String {
        inputForm.dailyRate?.currencyFormatted(forLocale: locale) ?? ""
    }
    
    @ViewBuilder private func calculatedDailyRateInfo(_ message: () -> Text) -> some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.redThree)
            message()
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
            Text("settings.rate.title", bundle: .module)
            Text(locale.currencySymbol ?? "$")
            TextField(text: $inputForm.rateAmountFieldText) {
                Text("settings.rate.placeholder", bundle: .module)
            }
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
                Text(rateType.localizedStringKey, bundle: .module).tag(rateType)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var runAtWeekendsToggle: some View {
        Toggle(isOn: $inputForm.runAtWeekends) {
            Text("settings.runAtWeekends.title", bundle: .module)
        }
        .toggleStyle(SwitchToggleStyle(tint: .redOne))
    }
}

private extension MeterSettings.Rate.RateType {
    
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .daily:
            return LocalizedStringKey("settings.rate.picker.daily")
        case .annual:
            return LocalizedStringKey("settings.rate.picker.annual")
        case .hourly:
            return LocalizedStringKey("settings.rate.picker.hour")
        }
    }
    
}


// MARK: - Previews

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
