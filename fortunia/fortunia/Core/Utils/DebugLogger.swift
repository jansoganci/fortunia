//
//  DebugLogger.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation

/// DebugLogger - Simple debug logging system
/// Provides structured logging for development and production builds
final class DebugLogger {
    
    // MARK: - Singleton
    static let shared = DebugLogger()
    private init() {}
    
    // MARK: - Properties
    private var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return UserDefaults.standard.bool(forKey: "DebugLoggingEnabled")
        #endif
    }
    
    // MARK: - Core Logging Methods
    
    /// Log debug message with category
    /// - Parameters:
    ///   - message: Log message
    ///   - category: Debug category (default: "DEBUG")
    func debug(_ message: String, category: String = "DEBUG") {
        guard isDebugMode else { return }
        print("🔧 [\(category)] \(message)")
    }
    
    /// Log network-related messages
    /// - Parameter message: Network log message
    func network(_ message: String) {
        debug(message, category: "NETWORK")
    }
    
    /// Log warning messages
    /// - Parameter message: Warning log message
    func warning(_ message: String) {
        debug(message, category: "WARNING")
    }
    
    /// Log quota-related messages
    /// - Parameter message: Quota log message
    func quota(_ message: String) {
        debug(message, category: "QUOTA")
    }
    
    /// Log auth-related messages
    /// - Parameter message: Auth log message
    func auth(_ message: String) {
        debug(message, category: "AUTH")
    }
    
    /// Log storage-related messages
    /// - Parameter message: Storage log message
    func storage(_ message: String) {
        debug(message, category: "STORAGE")
    }
    
    /// Log error messages
    /// - Parameter message: Error log message
    func error(_ message: String) {
        debug(message, category: "ERROR")
    }
    
    /// Log info messages with category
    /// - Parameters:
    ///   - message: Info log message
    ///   - category: Debug category
    func info(_ message: String, category: String = "INFO") {
        debug(message, category: category)
    }
}
