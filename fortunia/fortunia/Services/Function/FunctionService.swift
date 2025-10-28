
//
//  FunctionService.swift
//  fortunia
//
//  Created by Cursor AI on December 19, 2024
//

import Foundation
import Supabase
import Network

// MARK: - Function Service
/// FunctionService handles all Supabase Edge Function invocations in the Fortunia app.
/// 
/// This service provides:
/// - Edge Function invocation with parameter passing
/// - JSON serialization and response handling
/// - Error handling and logging for function operations
///
/// Dependencies:
/// - SupabaseService.shared for Supabase client access
/// - SupabaseService.shared for function configuration and error logging
///
/// Usage:
/// ```swift
/// let functionService = FunctionService.shared
/// let response = try await functionService.invokeEdgeFunction(name: "process-face-reading", parameters: params)
/// ```
///
/// - Note: This service uses a singleton pattern and should be accessed via `FunctionService.shared`
/// - Important: All methods are async and should be called with proper error handling
class FunctionService: ObservableObject {
    
    // MARK: - Singleton
    /// Shared instance of FunctionService
    /// 
    /// Use this singleton instance throughout the app to access function invocation functionality.
    /// The singleton pattern ensures consistent state management across the app.
    static let shared = FunctionService()
    
    @MainActor private let networkMonitor = NetworkMonitor.shared
    
    // MARK: - Private Initializer
    /// Private initializer for singleton pattern
    private init() {}
    
    // MARK: - Edge Function Methods
    
    /// Invoke a Supabase Edge Function
    /// - Parameters:
    ///   - name: Name of the Edge Function to invoke
    ///   - parameters: Dictionary of parameters to pass to the function
    /// - Returns: Raw Data response from the Edge Function
    /// - Throws: SupabaseFunctionError for invocation failures
    func invokeEdgeFunction(name: String, parameters: [String: Any]) async throws -> Data {
        print("🔥 [EDGE FUNCTION] invokeEdgeFunction START - Name: \(name)")
        print("🔥 [EDGE FUNCTION] Parameters: \(parameters)")
        
        // Check network connectivity before making the request
        guard await networkMonitor.hasInternetConnection else {
            print("🔥 [EDGE FUNCTION] ❌ No internet connection!")
            LocalizedDebugLogger.shared.logDebug("NETWORK", "No internet connection for Edge Function: \(name)")
            throw URLError(.notConnectedToInternet)
        }
        print("🔥 [EDGE FUNCTION] ✅ Network connection: OK")
        
        // Check Supabase client
        guard let supabase = SupabaseService.shared.supabase else {
            print("🔥 [EDGE FUNCTION] ❌ Supabase client not configured!")
            throw URLError(.userAuthenticationRequired)
        }
        print("🔥 [EDGE FUNCTION] ✅ Supabase client: OK")
        
        // Guest-friendly: Try to get session, but don't require it
        let session = try? await supabase.auth.session
        if session != nil {
            print("🔥 [EDGE FUNCTION] ✅ Auth session: OK (authenticated mode)")
        } else {
            print("🔥 [EDGE FUNCTION] 🟡 No session: Guest mode")
            LocalizedDebugLogger.shared.logDebug("AUTH", "Guest mode - no JWT required for Edge Function: \(name)")
        }
        
        LocalizedDebugLogger.shared.logEdgeFunction(name, success: false)
        
        do {
            // Add user_id to parameters if not present (for guest mode)
            var mutableParameters = parameters
            if parameters["user_id"] == nil {
                let guestUserId = UserDefaults.standard.string(forKey: "guest_user_id")
                if let guestUserId = guestUserId {
                    mutableParameters["user_id"] = guestUserId
                    print("🔥 [EDGE FUNCTION] 🟡 Guest mode: Added user_id to payload: \(guestUserId)")
                }
            }
            
            // Convert parameters to JSON data
            print("🔥 [EDGE FUNCTION] [STEP 1/4] Converting parameters to JSON...")
            let jsonData = try JSONSerialization.data(withJSONObject: mutableParameters)
            print("🔥 [EDGE FUNCTION] [STEP 1/4] ✅ JSON data size: \(jsonData.count) bytes")
            
            // Create function invoke options with optional Bearer token
            print("🔥 [EDGE FUNCTION] [STEP 2/4] Creating invoke options...")
            var headers: [String: String] = [:]
            if let validSession = try? await supabase.auth.session {
                headers["Authorization"] = "Bearer \(validSession.accessToken)"
                print("🔥 [EDGE FUNCTION] [STEP 2/4] ✅ Invoke options created with JWT")
            } else {
                print("🔥 [EDGE FUNCTION] [STEP 2/4] ✅ Invoke options created without JWT (guest mode)")
            }
            
            let options = FunctionInvokeOptions(
                headers: headers,
                body: jsonData
            )
            
            // Invoke Edge Function using SupabaseService's client
            print("🔥 [EDGE FUNCTION] [STEP 3/4] Calling supabase.functions.invoke(\(name))...")
            let response = try await supabase.functions.invoke(
                name,
                options: options,
                decode: { data, _ in data }
            )
            print("🔥 [EDGE FUNCTION] [STEP 3/4] ✅ Edge function responded! Size: \(response.count) bytes")
            
            LocalizedDebugLogger.shared.logEdgeFunction(name, success: true)
            print("🔥 [EDGE FUNCTION] ✅ Complete!")
            return response
            
        } catch {
            print("🔥 [EDGE FUNCTION] ❌ ERROR: \(error)")
            print("🔥 [EDGE FUNCTION] ❌ Error type: \(type(of: error))")
            LocalizedDebugLogger.shared.logEdgeFunction(name, success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logNetworkError(error, endpoint: "edge-function-\(name)", context: "invokeEdgeFunction")
            throw SupabaseError.functionInvocationFailed(name, error.localizedDescription)
        }
    }
    
    /// Invoke a Supabase Edge Function with generic response type
    /// - Parameters:
    ///   - name: Name of the Edge Function to invoke
    ///   - parameters: Dictionary of parameters to pass to the function
    /// - Returns: Decoded response of type T
    /// - Throws: SupabaseFunctionError for invocation failures
    func invokeFunction<T: Codable>(name: String, parameters: [String: Any]) async throws -> T {
        // Check network connectivity before making the request
        guard await networkMonitor.hasInternetConnection else {
            LocalizedDebugLogger.shared.logDebug("NETWORK", "No internet connection for Edge Function: \(name)")
            throw URLError(.notConnectedToInternet)
        }
        
        // Check Supabase client
        guard let supabase = SupabaseService.shared.supabase else {
            throw URLError(.userAuthenticationRequired)
        }
        
        // Guest-friendly: Try to get session, but don't require it
        let session = try? await supabase.auth.session
        if session != nil {
            LocalizedDebugLogger.shared.logDebug("AUTH", "Authenticated mode for Edge Function: \(name)")
        } else {
            LocalizedDebugLogger.shared.logDebug("AUTH", "Guest mode for Edge Function: \(name)")
        }
        
        LocalizedDebugLogger.shared.logEdgeFunction(name, success: false)
        
        do {
            // Add user_id to parameters if not present (for guest mode)
            var mutableParameters = parameters
            if parameters["user_id"] == nil {
                let guestUserId = UserDefaults.standard.string(forKey: "guest_user_id")
                if let guestUserId = guestUserId {
                    mutableParameters["user_id"] = guestUserId
                    LocalizedDebugLogger.shared.logDebug("GUEST", "Added user_id to payload: \(guestUserId)")
                }
            }
            
            // Convert parameters to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: mutableParameters)
            
            // Create function invoke options with optional Bearer token
            var headers: [String: String] = [:]
            if let session = session {
                headers["Authorization"] = "Bearer \(session.accessToken)"
            }
            
            let options = FunctionInvokeOptions(
                headers: headers,
                body: jsonData
            )
            
            // Invoke Edge Function using SupabaseService's client
            let response: T = try await supabase.functions.invoke(
                name,
                options: options
            )
            
            LocalizedDebugLogger.shared.logEdgeFunction(name, success: true)
            return response
            
        } catch {
            LocalizedDebugLogger.shared.logEdgeFunction(name, success: false)
            // Log detailed error information for debugging
            SupabaseService.shared.logNetworkError(error, endpoint: "edge-function-\(name)", context: "invokeFunction")
            throw SupabaseError.functionInvocationFailed(name, error.localizedDescription)
        }
    }
}

