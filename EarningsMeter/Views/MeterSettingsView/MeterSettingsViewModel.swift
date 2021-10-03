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
    @Published var formData: FormData = .empty
    @Published var isSaveButtonEnabled: Bool = false
    @Published var calculatedRateText: String = ""
    @Published var isCalculatedRateTextVisible: Bool = false
    @Published private(set) var currencySymbol: String = ""
    @Published private(set) var viewState: ViewState = .welcome

    let startPickerTitle: LocalizedStringKey = "settings.workingHours.startTime.title"
    let endPickerTitle: LocalizedStringKey = "settings.workingHours.endTime.title"
    let rateTitleText: LocalizedStringKey = "settings.rate.title"
    let ratePlaceholderText: LocalizedStringKey = "settings.rate.placeholder"
    let runAtWeekendsTitleText: LocalizedStringKey = "settings.runAtWeekends.title"
    let welcomeMessageTitle: LocalizedStringKey = "settings.welcome.message"
    private(set) var navigationBarTitle: LocalizedStringKey = ""
    private(set) var saveButtonText: LocalizedStringKey = ""
    

    private var cancelBag = Set<AnyCancellable>()
    
    init() {

        let appViewModel = inputs.environmentObjects
        
        let didSaveMeterSettings = appViewModel
                                    .flatMap { $0.outputActions.didSaveMeterSettings }
                                    .eraseToAnyPublisher()
        
        self.outputActions = OutputActions(didSave: didSaveMeterSettings,
                                           didTapInfo: inputs.tapInfo.eraseToAnyPublisher())
        
        // Once appViewModel (environment object) has been injected, set up initial view state and start reacting to changes
        appViewModel
            .sink { [weak self] appViewModel in
                self?.setUpInitialViewState(for: appViewModel)
            }
            .store(in: &cancelBag)
        
        $isStartPickerExpanded
            .when(equalTo: true)
            .assign(false, to: \.isEndPickerExpanded, on: self, ownership: .weak)
            .store(in: &cancelBag)

        $isEndPickerExpanded
            .when(equalTo: true)
            .assign(false, to: \.isStartPickerExpanded, on: self, ownership: .weak)
            .store(in: &cancelBag)
                
        $formData
            .map { [.annual, .hourly].contains($0.rateType) && $0.isValid }
            .assign(to: \.isCalculatedRateTextVisible, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        $formData
            .map(\.isValid)
            .assign(to: \.isSaveButtonEnabled, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        let validatedMeterSettings = $formData
            .filter(\.isValid)
            .combineLatest(appViewModel)
            .map { validatedForm, appViewModel in
                MeterSettings(formData: validatedForm, environment: appViewModel.environment)
            }

        validatedMeterSettings
            .combineLatest(appViewModel)
            .map { form, appViewModel in
                switch form.rate.type {
                case .annual, .hourly:
                    let currencyTextFormatter = appViewModel.environment.formatters.numberStyles.currency
                    let localizer = appViewModel.environment.stringLocalizer
                    let calculatedRateText = currencyTextFormatter.string(from: form.dailyRate as NSNumber) ?? ""
                    
                    if form.rate.type == .annual {
                        return String(format: localizer.localized("settings.rate.calculated %@"), calculatedRateText)
                    } else {
                        return String(format: localizer.localized("settings.rate.calculated.exact %@"), calculatedRateText)
                    }
                case .daily:
                    return ""
                }
            }
            .assign(to: \.calculatedRateText, on: self, ownership: .weak)
            .store(in: &cancelBag)
                
        inputs.save
            .withLatestFrom(validatedMeterSettings)
            .combineLatest(appViewModel)
            .sink { validatedMeterSettings, appViewModel in
                appViewModel.inputs.saveMeterSettings.send(validatedMeterSettings)
            }
            .store(in: &cancelBag)
    }
    
    private func setUpInitialViewState(for appViewModel: AppViewModel) {
        let environment = appViewModel.environment
        let rateTextFormatter = environment.formatters.numberStyles.decimal
        
        self.currencySymbol = rateTextFormatter.currencySymbol
        
        if let savedMeter = appViewModel.meterSettings {
            self.formData = FormData(meter: savedMeter,
                                     rateTextFormatter: rateTextFormatter,
                                     environment: environment)
            self.viewState = .edit
        } else {
            self.formData = FormData.welcome(environment: environment)
            self.viewState = .welcome
        }
        
        self.navigationBarTitle = viewState.navigationBarTitle
        self.saveButtonText = viewState.saveButtonText
    }
}

// MARK: - Inputs
extension MeterSettingsViewModel {
    
    struct Inputs {
        let environmentObjects = PassthroughSubject<AppViewModel, Never>()
        let save = PassthroughSubject<Void, Never>()
        let tapInfo = PassthroughSubject<Void, Never>()
    }
}

// MARK: - OutputActions
extension MeterSettingsViewModel {
    
    struct OutputActions {
        let didSave: AnyPublisher<MeterSettings?, Never>
        let didTapInfo: AnyPublisher<Void, Never>
    }

}

// MARK: - View model types
extension MeterSettingsViewModel {
    
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
        
        var startTime: Date
        var endTime: Date
        var runAtWeekends: Bool
        var rateType: MeterSettings.Rate.RateType
        private(set) var rateAmount: Double
        private(set) var isValid: Bool
        
        @Published var rateText: String
                
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
            
            let rateAmountNumber = $rateText.map {
                rateTextFormatter.number(from: $0) as? Double ?? 0
            }
            
            rateAmountNumber
                .assign(to: \.rateAmount, on: self, ownership: .weak)
                .store(in: &cancelBag)
            
            rateAmountNumber
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
        
        static let empty = FormData(startTime: Date(),
                                    endTime: Date(),
                                    runAtWeekends: false,
                                    rateText: "",
                                    rateType: .annual,
                                    rateTextFormatter: .decimalStyle)
                
        static func welcome(environment: AppEnvironment) -> FormData {
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
