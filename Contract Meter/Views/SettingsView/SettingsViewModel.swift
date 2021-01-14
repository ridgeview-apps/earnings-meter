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

final class SettingsViewModel: ObservableObject {
    
    let inputs: Inputs = Inputs()
    let outputActions: OutputActions
    
    // MARK: - State
    @Published var isStartPickerExpanded: Bool = false
    @Published var isEndPickerExpanded: Bool = false
    @Published var formData: FormData
    @Published var isSaveButtonEnabled: Bool = false
    @Published var firstResponderId: TextFieldInputId?

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
    
    init(appViewModel: AppViewModel) {
        
        if let savedMeter = appViewModel.meterSettings {
            formData = FormData(meter: savedMeter,
                                    rateTextFormatter: appViewModel.environment.formatters.numberStyles.decimal,
                                    environment: appViewModel.environment)
            viewState = .edit
        } else {
            formData = FormData.empty(environment: appViewModel.environment)
            viewState = .welcome
        }
        
        navigationBarTitle = viewState.navigationBarTitle
        saveButtonText = viewState.saveButtonText
        
        self.outputActions = OutputActions(
            didTapSave: appViewModel.outputActions.didSaveMeterSettings.eraseToAnyPublisher()
        )
        
        $isStartPickerExpanded
            .when(equalTo: true)
            .assign(false, to: \.isEndPickerExpanded, on: self, ownership: .weak)
            .store(in: &cancelBag)

        $isEndPickerExpanded
            .when(equalTo: true)
            .assign(false, to: \.isStartPickerExpanded, on: self, ownership: .weak)
            .store(in: &cancelBag)
                
        formData
            .$isValid
            .assign(to: \.isSaveButtonEnabled, on: self, ownership: .weak)
            .store(in: &cancelBag)
                        
        inputs.tappedTextField
            .map { $0 }
            .assign(to: \.firstResponderId, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        inputs.didSetFirstResponder
            .assignNil(to: \.firstResponderId, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        inputs.save
            .withLatestFrom($formData)
            .filter(\.isValid)
            .map {
                MeterSettings(formData: $0,
                              environment: appViewModel.environment)
            }
            .sink {
                appViewModel.inputs.saveMeterSettings.send($0)
            }
            .store(in: &cancelBag)
    }
    
}

// MARK: - Inputs
extension SettingsViewModel {
    
    struct Inputs {
        let tappedTextField = PassthroughSubject<TextFieldInputId, Never>()
        let didSetFirstResponder = PassthroughSubject<Void, Never>()
        let save = PassthroughSubject<Void, Never>()
    }
}

// MARK: - OutputActions
extension SettingsViewModel {
    
    struct OutputActions {
        let didTapSave: AnyPublisher<MeterSettings?, Never>
    }

}

// MARK: - View model types
extension SettingsViewModel {
    
    enum TextFieldInputId {
        case dailyRate
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
    
    final class FormData: ObservableObject {
        
        @Published var rateText: String
        @Published var startTime: Date
        @Published var endTime: Date
        @Published var runAtWeekends: Bool
        
        @Published private(set) var dailyRate: Double
        @Published private(set) var isValid: Bool
        
        private var cancelBag = Set<AnyCancellable>()

        init(rateText: String,
             startTime: Date,
             endTime: Date,
             runAtWeekends: Bool,
             rateTextFormatter: NumberFormatter = .decimalStyle) {
            self.rateText = rateText
            self.startTime = startTime
            self.endTime = endTime
            self.runAtWeekends = runAtWeekends
            self.isValid = false
            self.dailyRate = 0
            
            $rateText.map {
                rateTextFormatter.number(from: $0) as? Double ?? 0
            }
            .assign(to: \.dailyRate, on: self, ownership: .weak)
            .store(in: &cancelBag)
            
            $dailyRate
                .map { $0 > 0 }
                .assign(to: \.isValid, on: self, ownership: .weak)
                .store(in: &cancelBag)
        }
        
        convenience init(meter: MeterSettings,
                         rateTextFormatter: NumberFormatter = .decimalStyle,
                         environment: AppEnvironment) {
            self.init(rateText: rateTextFormatter.string(from: meter.dailyRate as NSNumber) ?? "",
                      startTime: meter.startTime.asLocalTimeToday(environment: environment),
                      endTime: meter.endTime.asLocalTimeToday(environment: environment),
                      runAtWeekends: meter.runAtWeekends,
                      rateTextFormatter: rateTextFormatter)
        }
                
        static func empty(environment: AppEnvironment) -> FormData {
            return FormData(rateText: "",
                             startTime: MeterTime(hour: 9, minute: 0)
                                .asLocalTimeToday(environment: environment),
                             endTime: MeterTime(hour: 17, minute: 30)
                                .asLocalTimeToday(environment: environment),
                             runAtWeekends: false)
        }
    }
}

private extension MeterSettings {
    init(formData: SettingsViewModel.FormData,
         environment: AppEnvironment) {
        self.init(dailyRate: formData.dailyRate,
                  startTime: MeterTime(date: formData.startTime, environment: environment),
                  endTime: MeterTime(date: formData.endTime, environment: environment),
                  runAtWeekends: formData.runAtWeekends)
    }
}


private extension MeterTime {
    init(date: Date,
         environment: AppEnvironment) {
        let comps = environment.currentCalendar().dateComponents([.hour, .minute], from: date)
        self.hour = comps.hour ?? 0
        self.minute = comps.minute ?? 0
    }
}
