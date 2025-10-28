//
//  NetworkMonitor.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import Network
import SwiftUI

/// NetworkMonitor provides real-time network connectivity monitoring
/// Uses NWPathMonitor to detect network status changes and updates UI accordingly
@MainActor
class NetworkMonitor: ObservableObject {
    
    static let shared = NetworkMonitor()
    
    // MARK: - Published Properties
    @Published var isConnected = true
    
    // MARK: - Private Properties
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let analyticsService = AnalyticsService.shared
    
    // MARK: - Initialization
    private init() {
        setupNetworkMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - Private Methods
    
    /// Setup network path monitoring
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                let wasConnected = self.isConnected
                let isNowConnected = path.status == .satisfied
                
                self.isConnected = isNowConnected
                
                // Log connectivity changes
                if wasConnected != isNowConnected {
                    if isNowConnected {
                        self.analyticsService.logEvent("network_connected")
                    } else {
                        self.analyticsService.logEvent("network_disconnected")
                    }
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    // MARK: - Public Methods
    
    /// Check if device is currently connected to internet
    var hasInternetConnection: Bool {
        return isConnected
    }
    
    /// Get current network status description
    var connectionStatus: String {
        return isConnected ? 
            NSLocalizedString("network_status_connected", comment: "Connected") :
            NSLocalizedString("network_status_disconnected", comment: "Disconnected")
    }
}
