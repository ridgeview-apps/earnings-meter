//
//  KeyValueStorage.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 19/05/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation

protocol KeyValueDataStoreType {
    func object(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: KeyValueDataStoreType { }

final class InMemoryKeyValueDataStore: KeyValueDataStoreType {
    
    private var storage =  [String: Any]()

    func object(forKey key: String) -> Any? {
        return storage[key]
    }
    
    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
    }
}
