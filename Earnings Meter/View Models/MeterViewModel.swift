//
//  MeterViewModel.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 21/06/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class MeterViewModel: ObservableObject {
    
    @Published private(set) var hireStatusPickerItems: [HireStatusPickerItem] = []
    @Published private(set) var currentReading: MeterReader.Reading

    let backgroundImage: String = "meter-background"
    let headerTextKey: LocalizedStringKey = "meter.header.earnings.today.title"
    
    let progressBarStartTimeText: String
    let progressBarEndTimeText: String
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(appEnvironment: AppEnvironment,
         actionHandlers: ActionHandlers,
         timeFormatter: DateFormatter = .shortTimeStyle,
         calendar: Calendar = .current,
         dateGenerator: DateGeneratorType = DateGenerator.default) {
        
        guard let meterSettings = appEnvironment.appState.userData.meterSettings else {
            progressBarStartTimeText = ""
            progressBarEndTimeText = ""
            currentReading = .offDuty(amountEarned: 0, progress: 0)
            return
        }
        
        progressBarStartTimeText = timeFormatter.string(from: meterSettings.startTime.asDateTimeToday(in: calendar,
                                                                                                      dateGenerator: dateGenerator))
        progressBarEndTimeText = timeFormatter.string(from: meterSettings.endTime.asDateTimeToday(in: calendar,
                                                                                                  dateGenerator: dateGenerator))
        
        let meterReader = MeterReader(meterSettings: meterSettings)
        currentReading = meterReader.currentReading
        
        meterReader
            .$currentReading
            .sink { [weak self] currentReading in
                guard let self = self else { return }
                self.hireStatusPickerItems = HireStatusPickerItem.all(selectedValue: currentReading.hireStatusPickerId)
                self.currentReading = currentReading
            }
            .store(in: &cancelBag)
        
        inputs.onTapSettingsButton
            .sink(receiveValue: actionHandlers.onTappedSettings)
            .store(in: &cancelBag)
        
        inputs.onAppear
            .sink(receiveValue: meterReader.start)
            .store(in: &cancelBag)
        
        inputs.onDisappear
            .sink(receiveValue: meterReader.stop)
            .store(in: &cancelBag)
    }
    
    // MARK: - Inputs
    let inputs = Inputs()
    
    struct Inputs {
        fileprivate let onAppear = PassthroughSubject<Void, Never>()
        func appear() {
            onAppear.send()
        }
        
        let onDisappear = PassthroughSubject<Void, Never>()
        func disappear() {
            onDisappear.send()
        }
        
        let onTapSettingsButton = PassthroughSubject<Void, Never>()
        func tapSettingsButton() {
            onTapSettingsButton.send()
        }
    }
}

// MARK: - Data structures
extension MeterViewModel {
    
    struct ActionHandlers {
        var onTappedSettings: ActionHandler
    }
        
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

