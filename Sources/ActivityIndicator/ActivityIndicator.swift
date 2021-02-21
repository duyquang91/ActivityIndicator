//
//  ActivityIndicator.swift
//  ActivityIndicator
//
//  Created by Steve Dao on 21/02/2021.
//

import Foundation
import Combine

/**
Enables monitoring of sequence computation.
If there is at least one sequence computation in progress, `true` will be sent.
When all activities complete `false` will be sent.
*/
public final class ActivityIndicator {
    private struct ActivityToken<Source: Publisher>: Cancellable {
        let source: Source
        let cancelAction: () -> Void
        
        func asPublisher() -> Source {
            source
        }
        
        func cancel() {
            cancelAction()
        }
    }
    
    @Published
    private var relay = 0
    private let lock = NSRecursiveLock()
    
    var loading: AnyPublisher<Bool, Never> {
        $relay.map { $0 > 0 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public func trackActivityOfPublisher<Source: Publisher>(source: Source) -> Source {
        increment()
        return ActivityToken(source: source) {
            self.decrement()
        }.asPublisher()
    }
    
    private func increment() {
        lock.lock()
        relay += 1
        lock.unlock()
    }
    
    private func decrement() {
        lock.lock()
        relay -= 1
        lock.unlock()
    }
}

extension Publisher {
    public func trackActivity(_ activityIndicator: ActivityIndicator) -> Self {
        activityIndicator.trackActivityOfPublisher(source: self)
    }
}




