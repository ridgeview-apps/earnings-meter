import Foundation
import Combine
import SwiftUI

final class MeterViewModel: ObservableObject {
    
    let inputs: Inputs = Inputs()
    let outputActions: OutputActions
    
    // MARK: - State
    @Published var statusPickerItems: [MeterStatusPickerItem] = []
    @Published var currentReading: MeterReader.Reading

    let backgroundImage: String = "meter-background"
    let headerTextKey: LocalizedStringKey = "meter.header.earnings.today.title"
    let navigationTitleKey: LocalizedStringKey = "settings.navigation.title.meter"
    
    let progressBarStartTimeText: String
    let progressBarEndTimeText: String
    
    private var cancelBag = Set<AnyCancellable>()

    init(appViewModel: AppViewModel) {
        
        guard let meterSettings = appViewModel.meterSettings else {
            progressBarStartTimeText = ""
            progressBarEndTimeText = ""
            currentReading = .free
            outputActions = .empty
            return
        }
        
        self.outputActions = .init(
            didTapSettings: inputs.tapSettingsButton.eraseToAnyPublisher()
        )
        
        let timeFormatter = appViewModel.environment.formatters.dateStyles.shortTime
        progressBarStartTimeText = timeFormatter.string(from: meterSettings.startTime.asLocalTimeToday(environment: appViewModel.environment))
        progressBarEndTimeText = timeFormatter.string(from: meterSettings.endTime.asLocalTimeToday(environment: appViewModel.environment))
        
        let meterReader = MeterReader(environment: appViewModel.environment, meterSettings: meterSettings)
        currentReading = meterReader.currentReading
        
        meterReader
            .$currentReading
            .removeDuplicates()
            .sink { [weak self] currentReading in
                guard let self = self else { return }
                self.statusPickerItems = MeterStatusPickerItem.all(selectedValue: currentReading.status)
                self.currentReading = currentReading
            }
            .store(in: &cancelBag)
        
        inputs.appear
            .sink(receiveValue: meterReader.start)
            .store(in: &cancelBag)
        
        inputs.disappear
            .sink(receiveValue: meterReader.stop)
            .store(in: &cancelBag)
        
    }
}


// MARK: - Inputs
extension MeterViewModel {

    struct Inputs {
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
            case .finished:
                return LocalizedStringKey("meter.hireStatus.finished")
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

