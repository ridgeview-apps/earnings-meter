import Foundation
import Combine
import SwiftUI

final class MeterViewModel: ObservableObject {
    
    let inputs: Inputs = Inputs()
    let outputActions: OutputActions
    
    // MARK: - State
    @Published private(set) var statusPickerItems: [MeterStatusPickerItem] = []
    @Published private(set) var meterReader: MeterReader = .empty
    @Published private(set) var currentReading: MeterReader.Reading = .free(amountEarned: 0, progress: 0)
        
    let backgroundImage: String = "meter-background"
    let headerTextKey: LocalizedStringKey = "meter.header.earnings.today.title"
    let navigationTitleKey: LocalizedStringKey = "settings.navigation.title.meter"
    
    private(set) var progressBarStartTimeText: String = ""
    private(set) var progressBarEndTimeText: String = ""
    
    private var cancelBag = Set<AnyCancellable>()
        
    init() {
        
        self.outputActions = .init(
            didTapSettings: inputs.tapSettingsButton.eraseToAnyPublisher()
        )
        
        let appViewModel = inputs.environmentObjects
        
        // Once appViewModel environment is injected, start configuring things and reacting to state changes
        appViewModel
            .sink { [weak self] appViewModel in
                self?.setUpInitialViewState(for: appViewModel)
            }
            .store(in: &cancelBag)
        
        appViewModel
            .compactMap { appViewModel -> MeterReader? in
                guard let meterSettings = appViewModel.meterSettings else { return nil }
                return MeterReader(environment: appViewModel.environment, meterSettings: meterSettings)
            }
            .assign(to: \.meterReader, on: self, ownership: .weak)
            .store(in: &cancelBag)
        
        $meterReader
            .flatMap { $0.$currentReading }
            .removeDuplicates()
            .sink { [weak self] currentReading in
                guard let self = self else { return }
                self.statusPickerItems = MeterStatusPickerItem.all(selectedValue: currentReading.status)
                self.currentReading = currentReading
            }
            .store(in: &cancelBag)
        
        inputs.appear
            .sink { [weak self] in
                self?.meterReader.inputs.start.send()
            }
            .store(in: &cancelBag)
        
        inputs.disappear
            .sink { [weak self] in
                self?.meterReader.inputs.stop.send()
            }
            .store(in: &cancelBag)

    }
    
    private func setUpInitialViewState(for appViewModel: AppViewModel) {
        guard let meterSettings = appViewModel.meterSettings else {
            return
        }
        let environment = appViewModel.environment
        let timeFormatter = environment.formatters.dateStyles.shortTime
        
        progressBarStartTimeText = timeFormatter.string(from: meterSettings.startTime.asLocalTimeToday(environment: environment))
        progressBarEndTimeText = timeFormatter.string(from: meterSettings.endTime.asLocalTimeToday(environment: environment))
    }
}


// MARK: - Inputs
extension MeterViewModel {

    struct Inputs {
        let environmentObjects = PassthroughSubject<AppViewModel, Never>()
        let appear = PassthroughSubject<Void, Never>()
        let disappear = PassthroughSubject<Void, Never>()
        let tapSettingsButton = PassthroughSubject<Void, Never>()
    }
}

// MARK: - Outputs
extension MeterViewModel {
        
    struct OutputActions {
        let didTapSettings: AnyPublisher<Void, Never>
        
        static let empty = OutputActions(
            didTapSettings: Empty(completeImmediately: true).eraseToAnyPublisher()
        )
    }

}

// MARK: - Data structures
extension MeterViewModel {
    
    struct MeterStatusPickerItem: Identifiable {
        
        let id: MeterReaderStatus
        let isSelected: Bool
        let flashesWhenSelected: Bool
        
        var textLocalizedKey: LocalizedStringKey {
            switch id {
            case .free:
                return LocalizedStringKey("meter.hireStatus.free")
            case .atWork:
                return LocalizedStringKey("meter.hireStatus.atWork")
            }
        }
        
        static func all(selectedValue: MeterReaderStatus) -> [MeterStatusPickerItem] {
            MeterReaderStatus.allCases.map {
                MeterStatusPickerItem(id: $0,
                                      isSelected: $0 == selectedValue,
                                      flashesWhenSelected: $0 == .atWork)
            }
        }
    }
}

