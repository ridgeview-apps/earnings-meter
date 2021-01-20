import Foundation
import SwiftUI
import Combine
import Introspect

struct SettingsView: View {
    
    @ObservedObject private var viewModel: SettingsViewModel
    private let onSave: (MeterSettings?) -> Void
    
    init(appViewModel: AppViewModel,
         onSave: @escaping (MeterSettings?) -> Void = { _ in }) {
        viewModel = SettingsViewModel(appViewModel: appViewModel)
        self.onSave = onSave
    }
    
    var body: some View {
        Form {
            Section(header: sectionHeader) {
                rateDetails
                    .padding([.top, .bottom], 12)
                ExpandableTimePicker(title: "settings.workingHours.startTime.title",
                                     selectedTime: $viewModel.formData.startTime,
                                     isExpanded: $viewModel.isStartPickerExpanded)
                ExpandableTimePicker(title: "settings.workingHours.endTime.title",
                                     selectedTime: $viewModel.formData.endTime,
                                     isExpanded: $viewModel.isEndPickerExpanded)
                runAtWeekendsToggle
            }
        }
        .navigationBarTitle(viewModel.navigationBarTitle)
        .navigationBarItems(trailing: saveButton)
        .dismissesKeyboardOnDrag()
        .navigationViewStyle(StackNavigationViewStyle())
        .animation(nil)
        .onReceive(viewModel.outputActions.didTapSave, perform: onSave)
    }
    
    private var sectionHeader: some View {
        if viewModel.viewState == .welcome {
            return Text(viewModel.welcomeMessageTitle).eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }

    private var rateDetails: some View {
        VStack {
            rateTextField
            ratePicker
            if viewModel.isCalculatedRateTextVisible {
                HStack {
                    Text(viewModel.calculatedRateText)
                        .font(.headline)
                        .foregroundColor(Color.redThree)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .padding(.top, 8)
            }
        }
    }
    
    private var rateTextField: some View {
        HStack {
            Text(viewModel.rateTitleText)
            Text(viewModel.currencySymbol)
            TextField(viewModel.ratePlaceholderText,
                      text: $viewModel.formData.rateText)
                .keyboardType(.decimalPad)
                .asFirstResponder(for: .dailyRate, on: viewModel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .modifier(TextFieldClearButton(text: $viewModel.formData.rateText))                
        }
        .onTapGesture {
            self.viewModel.inputs.tappedTextField.send(.dailyRate)
        }
    }
    
    private var ratePicker: some View {
        Picker("", selection: $viewModel.formData.rateType) {
            ForEach(MeterSettings.Rate.RateType.allCases) { rateType in
                Text(rateType.localizedStringKey).tag(rateType)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var runAtWeekendsToggle: some View {
        Toggle(isOn: $viewModel.formData.runAtWeekends) {
            Text(viewModel.runAtWeekendsTitleText)
        }
        .toggleStyle(SwitchToggleStyle(tint: .redOne))
    }
    
    private var saveButton: some View {
        Button(action: viewModel.inputs.save.send) {
            Text(viewModel.saveButtonText)
        }
        .accentColor(Color.redThree)
        .disabled(!viewModel.isSaveButtonEnabled)
    }
}

private extension MeterSettings.Rate.RateType {
    
    var localizedStringKey: LocalizedStringKey {
        switch self {
        case .daily:
            return LocalizedStringKey("settings.rate.picker.daily")
        case .annual:
            return LocalizedStringKey("settings.rate.picker.annual")
        }
    }
    
}

private extension View {
    
    func asFirstResponder(for textFieldInputId: SettingsViewModel.TextFieldInputId,
                          on viewModel: SettingsViewModel) -> some View {
        introspectTextField { textField in
            if viewModel.firstResponderId == textFieldInputId {
                textField.becomeFirstResponder()
                viewModel.inputs.didSetFirstResponder.send()
            }
        }
    }
}

// MARK: - Previews
#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView(appViewModel: .preview(meterSettings: nil))
                .embeddedInNavigationView()
                .previewDisplayName("Welcome state")
            SettingsView(appViewModel: .preview(meterSettings: .fake(ofType: .weekdayOnlyMeter)))
                .embeddedInNavigationView()
                .previewDisplayName("Edit state")
            SettingsView(appViewModel: .preview(meterSettings: .fake(ofType: .weekdayOnlyMeter)))
                .embeddedInNavigationView()
                .previewDisplayName("Dark mode")
                .previewOption(colorScheme: .dark)
        }
    }    
}
#endif
