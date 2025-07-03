//
//  RetryService.swift
//  INetKit
//
//  Created by Taiyou on 2025/6/27.
//

import Foundation
import SUtilKit

public struct ServiceKRetry: Sequence, Sendable {
    /// Default service
    static let `default` = ServiceKRetry(strategy: .exponential())
    
    public let strategy: Strategy
    
    //====================================
    
    /// - Parameter strategy: Retry strategy ``RetryService.Strategy``
    public init(strategy: Strategy){
        self.strategy = strategy
    }
    
    /// - Returns: Retry delays iterator
    public func makeIterator() -> InteratorRetry {
        return InteratorRetry(service: self)
    }
    
    ///retry interator
    public struct InteratorRetry: IteratorProtocol{
        ///Current amount of retries
        public private(set) var retries: UInt = 0
        
        ///Retry strategy
        public let strategy: Strategy
        
        ///A time after which stop producing sequence
        public let deadline:DispatchTime
        
        /// Validate current iteration
        var isValid: Bool {
            guard deadline >=  .now() else { return false }
            let max  = strategy.maximumRetries
            guard max > retries && max != 0 else { return false }
            return true
        }
        
        ///- Parameter service: Retry service ``ServiceRetry``
        init(service:ServiceKRetry) {
            self.strategy = service.strategy
            self.deadline = .now() + strategy.timeout.toDispatchTimeInterval()
        }
        
        /// Returns the next delay amount in nanoseconds, or `nil`.
        public mutating func next() -> UInt64? {
            guard isValid else { return nil }
            defer { retries += 1 }
            
            switch strategy{
            case.constant(retry: _, duration: let duration, timeout: _):
                if let value = duration.toDouble() {
                    let delay = value * 1e+9
                    return UInt64(delay)
                }
            case.exponential(retry: _, multiplier: let multiplier, duration: let duration, timeout: _):
                if let duration = duration.toDouble() {
                    let value = duration*pow(multiplier, Double(retries))
                    let delay = value * 1e+9
                    return UInt64(delay)
                }
            }
            return nil
        }
    }
}
