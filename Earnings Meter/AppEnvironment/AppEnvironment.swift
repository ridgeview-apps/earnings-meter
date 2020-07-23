//
//  AppEnvironment.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 18/05/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
import Combine

struct AppEnvironment {
    let appState: AppState
    let services: Services
    let dateGenerator: DateGeneratorType
    
    private enum AppEnvironmentType {
        case real
        case preview
        case unitTest
    }
    
    static let preview: AppEnvironment = make(for: .preview)
    static let real: AppEnvironment = make(for: .real)
    static let unitTest: AppEnvironment = make(for: .unitTest)
    
    private static func make(for environment: AppEnvironmentType) -> AppEnvironment {
        switch environment {
        case .real:
            let appState = AppState()
            return .init(appState: appState,
                         services: .init(userData: .init(appState: appState,
                                                         keyValueStore: UserDefaults.standard)),
                         dateGenerator: DateGenerator.default)
        case .preview, .unitTest:
            let appState = AppState()
            return .init(appState: appState,
                         services: .init(userData: .init(appState: appState,
                                                         keyValueStore: InMemoryKeyValueDataStore())),
                        dateGenerator: FakeDateGenerator())
        }
    }
    
    func load() {
        services.userData.load()
    }
}


extension AppEnvironment {
    
    struct Services {
        let userData: UserDataService
    }
}
