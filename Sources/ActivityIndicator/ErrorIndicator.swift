//
//  ErrorIndicator.swift
//  ActivityIndicator
//
//  Created by Steve Dao on 24/02/2021.
//

import Foundation
import Combine

/**
 Enables monitoring of sequence computation.
 If there is at least one sequence computation in progress, `true` will be sent.
 When all activities complete `false` will be sent.
 */
public final class ErrorIndicator {
    private struct ActivityToken<Source: Publisher> {
        let source: Source
        let errorAction: (Source.Failure) -> Void
        
        func asPublisher() -> AnyPublisher<Source.Output, Never> {
            source.handleEvents(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    errorAction(error)
                }
            })
            .catch { _ in Empty(completeImmediately: true) }
            .eraseToAnyPublisher()
        }
    }
    
    @Published
    private var relay: Error?
    private let lock = NSRecursiveLock()
    
    public var errors: AnyPublisher<Error, Never> {
        $relay.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    public init() {}
    
    public func trackErrorOfPublisher<Source: Publisher>(source: Source) -> AnyPublisher<Source.Output, Never> {
        return ActivityToken(source: source) { error in
            self.lock.lock()
            self.relay = error
            self.lock.unlock()
        }.asPublisher()
    }
}

extension Publisher {
    public func trackError(_ errorIndicator: ErrorIndicator) -> AnyPublisher<Self.Output, Never> {
        errorIndicator.trackErrorOfPublisher(source: self)
    }
}




