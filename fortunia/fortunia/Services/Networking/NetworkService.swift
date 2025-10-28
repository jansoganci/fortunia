//
//  NetworkService.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation
import Combine

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError>
    func uploadImage(_ data: Data, fileName: String) -> AnyPublisher<String, NetworkError>
}

// MARK: - Network Service
class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let baseURL: String
    
    init() {
        self.baseURL = AppConstants.API.baseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConstants.API.timeout
        config.timeoutIntervalForResource = AppConstants.API.timeout * 2
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Generic Request
    func request<T: Codable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError> {
        guard let url = endpoint.url(baseURL: baseURL) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        if let body = endpoint.body {
            request.httpBody = body
        }
        
        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return NetworkError.decodingError
                } else {
                    return NetworkError.unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Image Upload
    func uploadImage(_ data: Data, fileName: String) -> AnyPublisher<String, NetworkError> {
        // Implementation will be added when Supabase is configured
        return Just("https://example.com/\(fileName)")
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - API Endpoint Protocol
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
}

extension APIEndpoint {
    func url(baseURL: String) -> URL? {
        return URL(string: "\(baseURL)\(path)")
    }
}

// MARK: - HTTP Methods
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

// MARK: - Network Errors
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case networkError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("network_invalid_url", comment: "Invalid URL") // localized
        case .noData:
            return NSLocalizedString("network_no_data", comment: "No data received") // localized
        case .decodingError:
            return NSLocalizedString("network_decoding_error", comment: "Failed to decode response") // localized
        case .serverError(let code):
            let localizedServerError = NSLocalizedString("network_server_error", comment: "Server error") // localized
            return "\(localizedServerError): \(code)"
        case .networkError(let error):
            let localizedNetworkError = NSLocalizedString("network_network_error", comment: "Network error") // localized
            return "\(localizedNetworkError): \(error.localizedDescription)"
        case .unknown(let error):
            let localizedUnknownError = NSLocalizedString("network_unknown_error", comment: "Unknown error") // localized
            return "\(localizedUnknownError): \(error.localizedDescription)"
        }
    }
}
