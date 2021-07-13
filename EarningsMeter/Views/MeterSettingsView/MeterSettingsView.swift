import Foundation
import SwiftUI
import Combine
import Introspect

struct MeterSettingsView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel: MeterSettingsViewModel = .init()
    private(set) var onSave: (MeterSettings?) -> Void = { _ in }
    private(set) var onTappedInfo: () -> Void = {}
    
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
        .onAppear {
            viewModel.inputs.environmentObjects.send(appViewModel)
        }
        .navigationBarTitle(viewModel.navigationBarTitle)
        .navigationBarItems(leading: infoButton, trailing: saveButton)
        .dismissesKeyboardOnDrag()
        .onReceive(viewModel.outputActions.didSave, perform: onSave)
        .onReceive(viewModel.outputActions.didTapInfo, perform: onTappedInfo)
    }
    
    @ViewBuilder private var sectionHeader: some View {
        if viewModel.viewState == .welcome {
            Text(viewModel.welcomeMessageTitle)
        } else {
            EmptyView()
        }
    }

    private var rateDetails: some View {
        VStack {
            if viewModel.isCalculatedRateTextVisible {
                calculatedDailyRateText
                    .padding(.bottom, 8)
            }
            rateTextField
            ratePicker
        }
    }
    
    private var calculatedDailyRateText: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.redThree)
            Text(viewModel.calculatedRateText)
                .font(.headline)
                .foregroundColor(.redThree)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(8)
        .roundedBorder(Color.redThree, lineWidth: 2)
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
    
    private var infoButton: some View {
        Button(action: viewModel.inputs.tapInfo.send) {
            Image(systemName: "info.circle")
                .imageScale(.large)
                .padding([.top, .bottom, .trailing])
        }
        .accentColor(Color.redThree)
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

private extension View {
    
    func asFirstResponder(for textFieldInputId: MeterSettingsViewModel.TextFieldInputId,
                          on viewModel: MeterSettingsViewModel) -> some View {
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
            MeterSettingsView()
                .environmentObject(AppViewModel.fake(ofType: .welcomeState))
                .embeddedInNavigationView()
                .previewDisplayName("Welcome state")
            MeterSettingsView()
                .environmentObject(AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewDisplayName("Edit state")
            MeterSettingsView()
                .environmentObject(AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewDisplayName("Dark mode")
                .previewOption(colorScheme: .dark)
            MeterSettingsView()
                .environmentObject(AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewDisplayName("iPad")
                .previewOption(deviceType: .iPad_Pro_9_7_inch)
        }
//        .previewOption(locale: .fr) /* French language */
//        .previewOption(locale: .es) /*/ Spanish language */
//        .previewOption(contentSize: .extraExtraExtraLarge) /* XXL text */
    }
}
#endif
