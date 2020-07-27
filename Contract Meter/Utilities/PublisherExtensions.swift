//
//  Publisher+.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 03/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation
import Combine
import CombineExt

extension Publisher {
    
    func map<T>(to specificValue: T) -> AnyPublisher<T, Failure> {
        map { _ in specificValue }
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output: Equatable {
    
    func when(equalTo targetValue: Output) -> AnyPublisher<Output, Failure> {
        filter { $0 == targetValue }.eraseToAnyPublisher()
    }
}

extension Publisher where Self.Failure == Never {

    // Assigns a specific value to a target keypath
    func assign<Object: AnyObject, Value>(
        _ specificValue: Value,
        to targetKeyPath: ReferenceWritableKeyPath<Object, Value>,
        on targetObject: Object,
        ownership: ObjectOwnership = .strong) -> AnyCancellable {
        
        map(to: specificValue)
            .assign(to: targetKeyPath, on: targetObject, ownership: ownership)
    }
    
    // Assign nil to a target keypath
    func assignNil<Object: AnyObject, Value>
        (to targetKeyPath: ReferenceWritableKeyPath<Object, Value?>,
         on targetObject: Object,
         ownership: ObjectOwnership = .strong) -> AnyCancellable {
        
        map(to: nil)
            .assign(to: targetKeyPath, on: targetObject, ownership: ownership)
    }
    
    // Assigns (binds) a keypath directly to another keypath
    public func assign<Object: AnyObject, Value>(
        _ sourceKeyPath: KeyPath<Self.Output, Value>,
        to targetKeyPath: ReferenceWritableKeyPath<Object, Value>,
        on targetObject: Object,
        ownership: ObjectOwnership = .strong)
        -> AnyCancellable {
            
        map(sourceKeyPath)
            .assign(to: targetKeyPath, on: targetObject, ownership: ownership)
    }

}