//
//  BaseViewModel.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation
import Combine

// MARK: - Base ViewModel
@MainActor
class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isErrorPresented = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Error Handling
    func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        isErrorPresented = true
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
        isErrorPresented = false
    }
    
    // MARK: - Loading State
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    // MARK: - Cancellables Management
    func addCancellable(_ cancellable: AnyCancellable) {
        cancellables.insert(cancellable)
    }
    
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - View State
enum ViewState {
    case idle
    case loading
    case success
    case error(String)
}

// MARK: - View State Protocol
protocol ViewStateProtocol {
    var viewState: ViewState { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
}
