//
//  UtilServiceRetry.swift
//  ISwiftKit.Service
//
//  Created by Taiyou on 2025/7/10.
//
import Foundation

public extension ServiceRetry{
    enum Strategy :Sendable{
        /// Constant delay between retries
        case constant(
            retry: UInt = 5,
            duration: DispatchTimeInterval = .seconds(2),
            timeout: DispatchTimeInterval = .seconds(Int.max)
        )
        
        /// Exponential backoff is a strategy in which you increase the delays between retries.
        case exponential(
            retry: UInt = 3,
            multiplier: Double = 2.0,
            duration: DispatchTimeInterval = .seconds(2),
            timeout: DispatchTimeInterval = .seconds(Int.max)
        )
        
        /// Max amount of retries
        var maximumRetries: UInt{
            switch self {
            case .constant(retry: let retry, duration: _, timeout: _):
                return retry
            case .exponential(retry: let retry, multiplier: _, duration: _, timeout: _):
                return retry
            }
        }
        
        ///Duration between retries
        var duration: DispatchTimeInterval {
            switch self {
            case .constant(retry: _, duration: let duration, timeout: _):
                return duration
            case .exponential(retry: _, multiplier: _, duration: let duration, timeout: _):
                return duration
            }
        }
        
        ///Max time stop interating
        var timeout: DispatchTimeInterval {
            switch self{
            case.constant(retry: _, duration: _, timeout: let timeout):
                return timeout
            case .exponential(retry: _, multiplier: _, duration: _, timeout: let timeout):
                return timeout
            }
        }
    }
}
