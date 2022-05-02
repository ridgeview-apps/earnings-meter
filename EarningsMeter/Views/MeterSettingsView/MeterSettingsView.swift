import Foundation
import SwiftUI
import Combine
import Introspect

struct MeterSettingsView: View {
    
    let appViewModel: AppViewModel
    let onSave: (MeterSettings?) -> Void
    let onTappedInfo: () -> Void

    @StateObject private var viewModel: MeterSettingsViewModel
    @FocusState private var isRateTextFieldFocused: Bool
    
    init(
        appViewModel: AppViewModel,
        onSave: @escaping (MeterSettings?) -> Void = { _ in },
        onTappedInfo: @escaping () -> Void = {}
    ) {
        self.appViewModel = appViewModel
        self.onSave = onSave
        self.onTappedInfo = onTappedInfo
        self._viewModel = StateObject(wrappedValue: MeterSettingsViewModel(appViewModel: appViewModel))
    }
    
    var body: some View {
        List {
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
        .animation(.default, value: viewModel.isCalculatedRateTextVisible)
    }
    
    private var calculatedDailyRateText: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(.redThree)
            Text(viewModel.calculatedRateText)
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
            Text(viewModel.rateTitleText)
            Text(viewModel.currencySymbol)
            TextField(viewModel.ratePlaceholderText,
                      text: $viewModel.formData.rateText)
                .keyboardType(.decimalPad)
                .focused($isRateTextFieldFocused)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .modifier(TextFieldClearButton(text: $viewModel.formData.rateText))                
        }
        .onTapGesture {
            isRateTextFieldFocused = true
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

// MARK: - Previews
#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MeterSettingsView(
                appViewModel: AppViewModel.fake(ofType: .welcomeState)
            )
            .embeddedInNavigationView()
            .previewDisplayName("Welcome state")
            
            MeterSettingsView(
                appViewModel: AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700))
            )
            .embeddedInNavigationView()
            .previewDisplayName("Edit state")
            
            MeterSettingsView(
                appViewModel: AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700))
            )
            .embeddedInNavigationView()
            .previewDisplayName("Dark mode")
            .previewOption(colorScheme: .dark)
            
            MeterSettingsView(
                appViewModel: AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700))
            )
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
