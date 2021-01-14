//
//  RootViewModel.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 06/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
import Combine

final class RootViewModel: ObservableObject {
    
    let inputs = Inputs()
    
    // MARK: - State
    enum ChildViewState: String {
        case editSettings
        case meterRunning
    }
    
    @Published var childViewState: ChildViewState = .editSettings
    
    private var bag = [AnyCancellable]()
    
    init(appViewModel: AppViewModel) {
        
        let onFirstAppearance = inputs.appear.first()
        
        onFirstAppearance
            .sink(receiveValue: appViewModel.inputs.refreshData.send)
            .store(in: &bag)
        
        let onFirstRefresh = appViewModel.outputActions.didRefreshData.first()
        
        onFirstRefresh
            .map { meterSettings -> ChildViewState in
                meterSettings == nil ? .editSettings : .meterRunning
            }
            .assign(to: \.childViewState, on: self, ownership: .weak)
            .store(in: &bag)
        
        inputs
            .goToSettings
            .assign(ChildViewState.editSettings, to: \.childViewState, on: self, ownership: .weak)
            .store(in: &bag)
        
        inputs
            .closeSettings
            .assign(ChildViewState.meterRunning, to: \.childViewState, on: self, ownership: .weak)
            .store(in: &bag)
    }
}

// MARK: - Inputs
extension RootViewModel {
    struct Inputs {
        let appear = PassthroughSubject<Void, Never>()
        let goToSettings = PassthroughSubject<Void, Never>()
        let closeSettings = PassthroughSubject<Void, Never>()
    }
}
