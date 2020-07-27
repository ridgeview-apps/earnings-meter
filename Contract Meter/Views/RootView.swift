//
//  RootView.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 16/01/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import SwiftUI
import Combine

struct RootView: View {

    private let appEnvironment: AppEnvironment
    @ObservedObject private var viewModel: RootViewModel
    
    init(appEnvironment: AppEnvironment) {
        self.appEnvironment = appEnvironment
        self.viewModel = RootViewModel(appEnvironment: appEnvironment)
    }
    
    var body: some View {
        ZStack {
            rootView
                .id(viewModel.state)
                .transition(.opacity)
        }
        .animation(.default)
    }
    
    private var rootView: some View {
        switch viewModel.state {
        case .showSettings:
            return SettingsView(appEnvironment: appEnvironment,
                                onSave: {
                                    self.viewModel.inputs.handle(action: .didSaveSettings)
                                })
                                .asAnyView
        case .showMeter:
            return MeterView(appEnvironment: appEnvironment,
                             onTappedSettings: {
                                self.viewModel.inputs.handle(action: .goToSettings)
                             })
                             .asAnyView
        }
    }
}

// MARK - Previews
struct RootView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            RootView.meterRunningPreview
            RootView.setupModePreview
        }
    }
}
    
private extension RootView {
    static var meterRunningPreview: RootView {
        let appEnvironment = AppEnvironment.preview
        appEnvironment.appState.userData.meterSettings = .fake()
        return RootView(appEnvironment: appEnvironment)
    }
    
    static var setupModePreview: RootView {
        let appEnvironment = AppEnvironment.preview
        appEnvironment.appState.userData.meterSettings = nil
        return RootView(appEnvironment: appEnvironment)
    }
    
}

