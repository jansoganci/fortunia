//
//  HistoryViewModel.swift
//  fortunia
//
//  Created by Cursor AI on January 26, 2025
//

import Foundation
import SwiftUI

/// Simple, focused History ViewModel - following Jobs' philosophy of radical simplicity
@MainActor
class HistoryViewModel: ObservableObject {
    @Published var readings: [FortuneReading] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseService.shared
    
    /// Fetch all readings for current user
    func loadReadings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let client = supabase.supabase else {
                throw SupabaseError.authenticationFailed
            }
            
            // Get current user ID
            let currentUser = try await client.auth.session.user
            let userId = currentUser.id
            
            // Fetch readings from database - simple query, no complexity
            let response: [FortuneReading] = try await client
                .from("readings")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            
            readings = response
            isLoading = false
            
            DebugLogger.shared.info("Loaded \(readings.count) readings from history", category: "UI")
            
        } catch {
            DebugLogger.shared.warning("Failed to load readings: \(error.localizedDescription)")
            errorMessage = "Failed to load history"
            isLoading = false
        }
    }
    
    /// Delete a specific reading
    func deleteReading(_ reading: FortuneReading) async {
        do {
            guard let client = supabase.supabase else {
                throw SupabaseError.authenticationFailed
            }
            
            try await client
                .from("readings")
                .delete()
                .eq("id", value: reading.id)
                .execute()
            
            // Remove from local array
            readings.removeAll { $0.id == reading.id }
            
            DebugLogger.shared.info("Deleted reading: \(reading.id)", category: "UI")
            
        } catch {
            DebugLogger.shared.warning("Failed to delete reading: \(error.localizedDescription)")
        }
    }
    
    /// Refresh readings - simple reload
    func refresh() async {
        await loadReadings()
    }
}

