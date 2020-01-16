//
//  SettingsViewModel.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 24/05/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import CombineExt

// MARK: - Settings view model

final class SettingsViewModel: ObservableObject {
    
    // MARK: - Outputs & bindings
    @Published var isStartPickerExpanded: Bool = false
    @Published var isEndPickerExpanded: Bool = false
    @Published var formInput: FormInput
    @Published private(set) var isSaveButtonEnabled: Bool = false
    @Published private(set) var firstResponderId: TextFieldInputId?

    let startPickerTitle: LocalizedStringKey = "settings.workingHours.startTime.title"
    let endPickerTitle: LocalizedStringKey = "settings.workingHours.endTime.title"
    let rateTitleText: LocalizedStringKey = "settings.rate.title"
    let ratePlaceholderText: LocalizedStringKey = "settings.rate.placeholder"
    let runAtWeekendsTitleText: LocalizedStringKey = "settings.runAtWeekends.title"
    let welcomeMessageTitle: LocalizedStringKey = "settings.welcome.message"
    let navigationBarTitle: LocalizedStringKey
    let saveButtonText: LocalizedStringKey
    let viewState: ViewState
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(appState: AppState,
         userDataService: UserDataService,
         actionHandlers: ActionHandlers,
         rateTextFormatter: NumberFormatter = .decimalStyle,
         calendar: Calendar = .current,
         dateGenerator: DateGeneratorType = DateGenerator.default) {
        
        if let savedMeter = appState.userData.meterSettings {
            formInput = FormInput(meter: savedMeter,
                                  rateTextFormatter: rateTextFormatter,
                                  calendar: calendar,
                                  dateGenerator: dateGenerator)
            viewState = .edit
        } else {
            formInput = .empty(calendar: calendar,
                               dateGenerator: dateGenerator)
            viewState = .welcome
        }
        
        navigationBarTitle = viewState.navigationBarTitle
        saveButtonText = viewState.saveButtonText
        
        $isStartPickerExpanded
            .when(equalTo: true)
            .assign(false, to: \.isEndPickerExpanded, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        $isEndPickerExpanded
            .when(equalTo: true)
            .assign(false, to: \.isStartPickerExpanded, on: self, ownership: .weak)
            .store(in: &cancelBag)
                
        $formInput
            .assign(\.isValid, to: \.isSaveButtonEnabled, on: self, ownership: .weak)
            .store(in: &cancelBag)
                        
        inputs.onTappedTextField
            .map { $0 }
            .assign(to: \.firstResponderId, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        inputs.onDidSetFirstResponder
            .assignNil(to: \.firstResponderId, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        inputs.onSave
            .withLatestFrom($formInput)
            .flatMap {
                userDataService.save(meterSettings: .init(formInput: $0,
                                                          calendar: calendar))
            }
            .sink(receiveValue: actionHandlers.onSave)
            .store(in: &cancelBag)
    }
    
    // MARK: - Inputs
    let inputs = Inputs()
    
    struct Inputs {
        fileprivate let onTappedTextField = PassthroughSubject<TextFieldInputId, Never>()
        func tapped(textFieldId: TextFieldInputId) {
            onTappedTextField.send(textFieldId)
        }
        
        fileprivate let onDidSetFirstResponder = PassthroughSubject<Void, Never>()
        func didSetFirstResponder() {
            onDidSetFirstResponder.send()
        }
        
        fileprivate let onSave = PassthroughSubject<Void, Never>()
        func save() {
            onSave.send()
        }
    }
}

// MARK: - View model types
extension SettingsViewModel {
    
    enum TextFieldInputId {
        case dailyRate
    }
    
    struct ActionHandlers {
        var onSave: (() -> Void)
    }
    
    enum ViewState {
        case welcome
        case edit
        
        var navigationBarTitle: LocalizedStringKey {
            switch self {
            case .welcome:
                return "settings.navigation.title.welcome"
            case .edit:
                return "settings.navigation.title.edit"
            }
        }
        
        var saveButtonText: LocalizedStringKey {
            switch self {
            case .welcome:
                return "settings.footer.button.title.start"
            case .edit:
                return "settings.footer.button.title.save"
            }
        }
    }
    
    final class FormInput: ObservableObject {
        
        @Published var rateText: String
        @Published var startTime: Date
        @Published var endTime: Date
        @Published var runAtWeekends: Bool
        
        private let rateTextFormatter: NumberFormatter
        
        var dailyRate: Double {
            return rateTextFormatter.number(from: rateText) as? Double ?? 0
        }

        init(rateText: String,
             startTime: Date,
             endTime: Date,
             runAtWeekends: Bool,
             rateTextFormatter: NumberFormatter = .decimalStyle) {
            self.rateText = rateText
            self.startTime = startTime
            self.endTime = endTime
            self.runAtWeekends = runAtWeekends
            self.rateTextFormatter = rateTextFormatter
        }
        
        convenience init(meter: AppState.MeterSettings,
                         rateTextFormatter: NumberFormatter = .decimalStyle,
                         calendar: Calendar,
                         dateGenerator: DateGeneratorType) {
            self.init(rateText: rateTextFormatter.string(from: meter.dailyRate as NSNumber) ?? "",
                      startTime: meter.startTime.asDateTimeToday(in: calendar,
                                                                 dateGenerator: dateGenerator),
                      endTime: meter.endTime.asDateTimeToday(in: calendar,
                                                             dateGenerator: dateGenerator),
                      runAtWeekends: meter.runAtWeekends,
                      rateTextFormatter: rateTextFormatter)
        }
        
        var isValid: Bool {
            return dailyRate > 0
        }
        
        static func empty(calendar: Calendar, dateGenerator: DateGeneratorType) -> FormInput {
            return FormInput(rateText: "",
                             startTime: MeterTime(hour: 9, minute: 0)
                                            .asDateTimeToday(in: calendar,
                                                             dateGenerator: dateGenerator),
                             endTime: MeterTime(hour: 17, minute: 30)
                                .asDateTimeToday(in: calendar,
                                                       dateGenerator: dateGenerator),
                             runAtWeekends: false)
        }
    }
}

private extension AppState.MeterSettings {
    init(formInput: SettingsViewModel.FormInput,
         calendar: Calendar) {
        self.init(dailyRate: formInput.dailyRate,
                  startTime: MeterTime(date: formInput.startTime, calendar: calendar),
                  endTime: MeterTime(date: formInput.endTime, calendar: calendar),
                  runAtWeekends: formInput.runAtWeekends)
    }
}
