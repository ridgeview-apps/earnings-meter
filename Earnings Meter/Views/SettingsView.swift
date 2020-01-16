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
    
    private var cancelBag = [AnyCancellable]()
    
    init(appEnvironment: AppEnvironment,
         onSave: @escaping ActionHandler = {}) {
        viewModel = SettingsViewModel(appState: appEnvironment.appState,
                                      userDataService: appEnvironment.services.userData,
                                      actionHandlers: .init(onSave: onSave))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: sectionHeader) {
                    rateTextField
                    ExpandableTimePicker(title: "settings.workingHours.startTime.title",
                                         selectedTime: $viewModel.formInput.startTime,
                                         isExpanded: $viewModel.isStartPickerExpanded)
                    ExpandableTimePicker(title: "settings.workingHours.endTime.title",
                                         selectedTime: $viewModel.formInput.endTime,
                                         isExpanded: $viewModel.isEndPickerExpanded)
                    runAtWeekendsToggle
                }
            }
            .navigationBarTitle(viewModel.navigationBarTitle)
            .navigationBarItems(trailing: saveButton)
            .uiTableViewBackgroundColor(.white)
            .uiTableViewDismissMode(.onDrag)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var sectionHeader: some View {
        if viewModel.viewState == .welcome {
            return Text(viewModel.welcomeMessageTitle).asAnyView
        } else {
            return EmptyView().asAnyView
        }
    }

    private var rateTextField: some View {
        HStack {
            Text(viewModel.rateTitleText)
            TextField(viewModel.ratePlaceholderText,
                      text: $viewModel.formInput.rateText)
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .asFirstResponder(for: .dailyRate, on: viewModel)
        }
        .onTapGesture {
            self.viewModel.inputs.tapped(textFieldId: .dailyRate)
        }
    }
    
    private var runAtWeekendsToggle: some View {
        Toggle(isOn: $viewModel.formInput.runAtWeekends) {
            Text(viewModel.runAtWeekendsTitleText)
        }
        .introspectSwitch {
            $0.onTintColor = .redOne
        }
    }
    
    private var saveButton: some View {
        Button(action: viewModel.inputs.save) {
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
                viewModel.inputs.didSetFirstResponder()
            }
        }
    }
}

// MARK: - Previews
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            settingsStateWelcome
                .previewDisplayName("Welcome state")
            UIElementPreview(settingsStateEdit)
        }
    }
    
    static var settingsStateWelcome: SettingsView {
        let appEnvironment = AppEnvironment.preview
        appEnvironment.appState.userData.meterSettings = nil
        return SettingsView(appEnvironment: .preview)
    }
    
    static var settingsStateEdit: SettingsView {
        let appEnvironment = AppEnvironment.preview
        appEnvironment.appState.userData.meterSettings = .fake()
        return SettingsView(appEnvironment: .preview)
    }
}
