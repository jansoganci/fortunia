//
//  AuthViewModel.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation
import SwiftUI

// MARK: - Auth View Model
class AuthViewModel: BaseViewModel {
    
    // MARK: - Auth Methods
    func signUp(email: String, password: String) async {
        isLoading = true
        
        do {
            // TODO: Implement Supabase sign up
            print("Sign up with email: \(email)")
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                handleError(error)
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        
        do {
            // TODO: Implement Supabase sign in
            print("Sign in with email: \(email)")
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                handleError(error)
            }
        }
    }
    
    func continueAsGuest() {
        // TODO: Set guest mode
        print("Continue as guest")
    }
    
    // MARK: - Error Handling
    override func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        isErrorPresented = true
        isLoading = false
    }
    
    override func clearError() {
        errorMessage = nil
        isErrorPresented = false
    }
}
