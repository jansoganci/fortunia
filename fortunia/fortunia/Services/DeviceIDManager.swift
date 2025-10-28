//
//  DeviceIDManager.swift
//  fortunia
//
//  Created by Cursor AI
//

import Foundation
import UIKit

/// DeviceIDManager handles device ID generation and persistence for guest users
/// Uses UIDevice.identifierForVendor or generates a UUID if not available
final class DeviceIDManager {
    
    // MARK: - Singleton
    static let shared = DeviceIDManager()
    private init() {}
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let deviceIDKey = "device_id"
    
    // MARK: - Get Device ID
    
    /// Get or create a persistent device ID
    /// - Returns: A unique device identifier that persists across app restarts
    func getOrCreateDeviceID() -> String {
        // Check if device ID already exists
        if let existingID = userDefaults.string(forKey: deviceIDKey) {
            DebugLogger.shared.quota("🔵 [DEVICE_ID] Using existing device ID: \(existingID)")
            return existingID
        }
        
        // Generate new device ID using identifierForVendor
        var deviceID: String
        
        if let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString {
            deviceID = identifierForVendor
            DebugLogger.shared.quota("🔵 [DEVICE_ID] Generated new device ID from identifierForVendor: \(deviceID)")
        } else {
            // Fallback: generate UUID
            deviceID = UUID().uuidString
            DebugLogger.shared.quota("🔵 [DEVICE_ID] Generated new device ID from UUID: \(deviceID)")
        }
        
        // Store device ID
        userDefaults.set(deviceID, forKey: deviceIDKey)
        userDefaults.synchronize()
        
        DebugLogger.shared.quota("✅ [DEVICE_ID] Device ID saved: \(deviceID)")
        return deviceID
    }
    
    /// Get existing device ID (returns nil if not created yet)
    /// - Returns: Device ID if exists, nil otherwise
    func getDeviceID() -> String? {
        return userDefaults.string(forKey: deviceIDKey)
    }
    
    /// Check if device ID exists
    /// - Returns: True if device ID is stored
    func hasDeviceID() -> Bool {
        return userDefaults.string(forKey: deviceIDKey) != nil
    }
    
    /// Clear device ID (useful when user signs up and converts from guest to authenticated)
    func clearDeviceID() {
        userDefaults.removeObject(forKey: deviceIDKey)
        DebugLogger.shared.quota("🔵 [DEVICE_ID] Device ID cleared")
    }
}
