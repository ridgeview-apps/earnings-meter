import Foundation
import Combine
import SwiftUI

final class MeterViewModel: ObservableObject {
    
    let inputs: Inputs = Inputs()
    let outputActions: OutputActions
    
    // MARK: - State
    @Published var hireStatusPickerItems: [HireStatusPickerItem] = []
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
            currentReading = .offDuty(amountEarned: 0, progress: 0)
            outputActions = .empty
            return
        }
        
        self.outputActions = .init(
            didTapSettings: inputs.tapSettingsButton.eraseToAnyPublisher(),
            didTapInfo: inputs.tapInfoButton.eraseToAnyPublisher()
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
                self.hireStatusPickerItems = HireStatusPickerItem.all(selectedValue: currentReading.hireStatusPickerId)
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
        let tapInfoButton = PassthroughSubject<Void, Never>()
    }
}

// MARK: - Outputs
extension MeterViewModel {
        
    struct OutputActions {
        let didTapSettings: AnyPublisher<Void, Never>
        let didTapInfo: AnyPublisher<Void, Never>
        
        static let empty = OutputActions(
            didTapSettings: Empty(completeImmediately: true).eraseToAnyPublisher(),
            didTapInfo: Empty(completeImmediately: true).eraseToAnyPublisher()
        )
    }

}

// MARK: - Data structures
extension MeterViewModel {
    
    struct HireStatusPickerItem: Identifiable {
        
        enum PickerId: String, CaseIterable {
            case hired
            case offDuty
        }
        
        let id: PickerId
        let isSelected: Bool
        
        var textLocalizedKey: LocalizedStringKey {
            switch id {
            case .hired:
                return LocalizedStringKey("meter.hireStatus.hired")
            case .offDuty:
                return LocalizedStringKey("meter.hireStatus.offDuty")
            }
        }
        
        static func all(selectedValue: HireStatusPickerItem.PickerId) -> [HireStatusPickerItem] {
            PickerId.allCases.map {
                HireStatusPickerItem(id: $0, isSelected: $0 == selectedValue)
            }
        }
    }
}

private extension MeterReader.Reading {
    
    var hireStatusPickerId: MeterViewModel.HireStatusPickerItem.PickerId {
        switch status {
        case .hired:
            return .hired
        case .offDuty:
            return .offDuty
        }
    }
}

