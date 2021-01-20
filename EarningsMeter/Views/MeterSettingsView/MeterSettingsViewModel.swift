import Foundation
import SwiftUI
import Combine
import CombineExt

final class MeterSettingsViewModel: ObservableObject {
    
    let inputs: Inputs = Inputs()
    let outputActions: OutputActions
    
    // MARK: - State
    @Published var isStartPickerExpanded: Bool = false
    @Published var isEndPickerExpanded: Bool = false
    @Published var formData: FormData
    @Published var isSaveButtonEnabled: Bool = false
    @Published var firstResponderId: TextFieldInputId?
    @Published var calculatedRateText: String = ""
    @Published var isCalculatedRateTextVisible: Bool = false

    let startPickerTitle: LocalizedStringKey = "settings.workingHours.startTime.title"
    let endPickerTitle: LocalizedStringKey = "settings.workingHours.endTime.title"
    let rateTitleText: LocalizedStringKey = "settings.rate.title"
    let ratePlaceholderText: LocalizedStringKey = "settings.rate.placeholder"
    let runAtWeekendsTitleText: LocalizedStringKey = "settings.runAtWeekends.title"
    let welcomeMessageTitle: LocalizedStringKey = "settings.welcome.message"
    let navigationBarTitle: LocalizedStringKey
    let saveButtonText: LocalizedStringKey
    let viewState: ViewState
    let currencySymbol: String

    private var cancelBag = Set<AnyCancellable>()
    
    init(appViewModel: AppViewModel) {
        let rateTextFormatter = appViewModel.environment.formatters.numberStyles.decimal
        let currencyTextFormatter = appViewModel.environment.formatters.numberStyles.currency
        let localizer = appViewModel.environment.stringLocalizer
        
        self.currencySymbol = rateTextFormatter.currencySymbol
        
        if let savedMeter = appViewModel.meterSettings {
            formData = FormData(meter: savedMeter,
                                rateTextFormatter: rateTextFormatter,
                                environment: appViewModel.environment)
            viewState = .edit
        } else {
            formData = FormData.empty(environment: appViewModel.environment)
            viewState = .welcome
        }
        
        navigationBarTitle = viewState.navigationBarTitle
        saveButtonText = viewState.saveButtonText
        
        self.outputActions = OutputActions(
            didSave: appViewModel.outputActions.didSaveMeterSettings.eraseToAnyPublisher()
        )
        
        $isStartPickerExpanded
            .when(equalTo: true)
            .assign(false, to: \.isEndPickerExpanded, on: self, ownership: .weak)
            .store(in: &cancelBag)

        $isEndPickerExpanded
            .when(equalTo: true)
            .assign(false, to: \.isStartPickerExpanded, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        inputs.tappedTextField
            .map { $0 }
            .assign(to: \.firstResponderId, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        inputs.didSetFirstResponder
            .assignNil(to: \.firstResponderId, on: self, ownership: .weak)
            .store(in: &cancelBag)
                
        $formData
            .map { $0.rateType == .annual && $0.isValid }
            .assign(to: \.isCalculatedRateTextVisible, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        formData
            .$isValid
            .assign(to: \.isSaveButtonEnabled, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        let validatedForm = $formData
            .filter(\.isValid)
            .map {
                MeterSettings(formData: $0, environment: appViewModel.environment)
            }

        validatedForm
            .map {
                switch $0.rate.type {
                case .annual:
                    let calculatedRateText = currencyTextFormatter.string(from: $0.dailyRate as NSNumber) ?? ""
                    let localizedString = String(format: localizer.localized("settings.rate.calculated %@"), calculatedRateText)
                    return localizedString
                case .daily:
                    return ""
                }
            }
            .assign(to: \.calculatedRateText, on: self, ownership: .weak)
            .store(in: &cancelBag)
                
        inputs.save
            .withLatestFrom(validatedForm)
            .sink {
                appViewModel.inputs.saveMeterSettings.send($0)
            }
            .store(in: &cancelBag)
    }
    
}

// MARK: - Inputs
extension MeterSettingsViewModel {
    
    struct Inputs {
        let tappedTextField = PassthroughSubject<TextFieldInputId, Never>()
        let didSetFirstResponder = PassthroughSubject<Void, Never>()
        let save = PassthroughSubject<Void, Never>()
    }
}

// MARK: - OutputActions
extension MeterSettingsViewModel {
    
    struct OutputActions {
        let didSave: AnyPublisher<MeterSettings?, Never>
    }

}

// MARK: - View model types
extension MeterSettingsViewModel {
    
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
    
    final class FormData {
        
        var startTime: Date
        var endTime: Date
        var runAtWeekends: Bool
        var rateType: MeterSettings.Rate.RateType
        
        @Published var rateText: String
        @Published var rateAmount: Double
        @Published var isValid: Bool
        
        private var cancelBag = Set<AnyCancellable>()

        init(startTime: Date,
             endTime: Date,
             runAtWeekends: Bool,
             rateText: String,
             rateType: MeterSettings.Rate.RateType,
             rateTextFormatter: NumberFormatter) {
            self.rateText = rateText
            self.startTime = startTime
            self.endTime = endTime
            self.runAtWeekends = runAtWeekends
            self.rateAmount = 0
            self.rateType = rateType
            self.isValid = false
            
            $rateText.map {
                rateTextFormatter.number(from: $0) as? Double ?? 0
            }
            .assign(to: \.rateAmount, on: self, ownership: .weak)
            .store(in: &cancelBag)
            
            $rateAmount
                .map { $0 > 0 }
                .assign(to: \.isValid, on: self, ownership: .weak)
                .store(in: &cancelBag)
        }
        
        
        convenience init(meter: MeterSettings,
                         rateTextFormatter: NumberFormatter = .decimalStyle,
                         environment: AppEnvironment) {
            self.init(startTime: meter.startTime.asLocalTimeToday(environment: environment),
                      endTime: meter.endTime.asLocalTimeToday(environment: environment),
                      runAtWeekends: meter.runAtWeekends,
                      rateText: rateTextFormatter.string(from: meter.rate.amount as NSNumber) ?? "",
                      rateType: meter.rate.type,
                      rateTextFormatter: rateTextFormatter)
        }
                
        static func empty(environment: AppEnvironment) -> FormData {
            return FormData(startTime: MeterTime(hour: 9, minute: 0)
                                .asLocalTimeToday(environment: environment),
                            endTime: MeterTime(hour: 17, minute: 30)
                                .asLocalTimeToday(environment: environment),
                            runAtWeekends: false,
                            rateText: "",
                            rateType: .annual,
                            rateTextFormatter: environment.formatters.numberStyles.decimal)
        }
    }
}

private extension MeterSettings {
    init(formData: MeterSettingsViewModel.FormData,
         environment: AppEnvironment) {
        self.init(rate: .init(amount: formData.rateAmount,
                              type: formData.rateType),
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