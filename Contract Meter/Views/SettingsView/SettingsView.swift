//
//  SettingsView.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 19/01/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

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
                rateTextField
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
        .uiTableViewBackgroundColor(.white)
        .uiTableViewDismissMode(.onDrag)
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(viewModel.outputActions.didTapSave, perform: onSave)
    }
    
    private var sectionHeader: some View {
        if viewModel.viewState == .welcome {
            return Text(viewModel.welcomeMessageTitle).eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }

    private var rateTextField: some View {
        HStack {
            Text(viewModel.rateTitleText)
            TextField(viewModel.ratePlaceholderText,
                      text: $viewModel.formData.rateText)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .asFirstResponder(for: .dailyRate, on: viewModel)
        }
        .onTapGesture {
            self.viewModel.inputs.tappedTextField.send(.dailyRate)
        }
    }
    
    private var runAtWeekendsToggle: some View {
        Toggle(isOn: $viewModel.formData.runAtWeekends) {
            Text(viewModel.runAtWeekendsTitleText)
        }
        .introspectSwitch {
            $0.onTintColor = .redOne
        }
    }
    
    private var saveButton: some View {
        Button(action: viewModel.inputs.save.send) {
            Text(viewModel.saveButtonText)
        }
        .disabled(!viewModel.isSaveButtonEnabled)
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
