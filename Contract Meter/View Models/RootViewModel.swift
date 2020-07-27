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
    
    enum ViewState: String, Identifiable {
        var id: String {
            return rawValue
        }
        case showSettings
        case showMeter
    }
    
    enum Action {
        case didSaveSettings
        case goToSettings
    }
    
    @Published private(set) var state: ViewState
    
    private var bag = [AnyCancellable]()
    
    init(appEnvironment: AppEnvironment) {
        state = appEnvironment.appState.userData.meterSettings == nil ? .showSettings : .showMeter
        
        inputs.onHandleAction
            .map { $0.viewState }
            .assign(to: \.state, on: self, ownership: .weak)
            .store(in: &bag)
    }
    
    // MARK: - Inputs
    let inputs = Inputs()
    
    struct Inputs {
        fileprivate let onHandleAction = PassthroughSubject<Action, Never>()
        func handle(action: Action) {
            onHandleAction.send(action)
        }
    }
}

extension RootViewModel.Action {
    var viewState: RootViewModel.ViewState {
        switch self {
        case .didSaveSettings:
            return .showMeter
        case .goToSettings:
            return .showSettings
        }
    }
}
