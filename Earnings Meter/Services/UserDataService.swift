//
//  UserDataService.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 06/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
import Combine

struct UserDataService {

    private enum DataKeys: String {
        case meterSettings
    }
    
    let appState: AppState
    let keyValueStore: KeyValueDataStoreType
        
    func load() {
        var decodedMeterSettings: AppState.MeterSettings?
        if let data = keyValueStore.object(forKey: DataKeys.meterSettings.rawValue) as? Data {
            decodedMeterSettings = try? JSONDecoder().decode(AppState.MeterSettings.self, from: data)
        }
        appState.userData.meterSettings = decodedMeterSettings
    }
    
    func save(meterSettings: AppState.MeterSettings?) -> AnyPublisher<Void, Never> {
        let encodedMeter = try? JSONEncoder().encode(meterSettings)
        keyValueStore.set(encodedMeter, forKey: DataKeys.meterSettings.rawValue)
        appState.userData.meterSettings = meterSettings
        return Just(()).eraseToAnyPublisher()
    }
}
