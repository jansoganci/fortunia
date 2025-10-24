//
//  User.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: UUID
    let email: String?
    let birthDate: Date?
    let birthTime: String?
    let birthCity: String?
    let birthCountry: String?
    let timezone: String
    let language: String
    let notificationEnabled: Bool
    let notificationTime: String?
    let createdAt: Date
    let lastActiveAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case birthDate = "birth_date"
        case birthTime = "birth_time"
        case birthCity = "birth_city"
        case birthCountry = "birth_country"
        case timezone
        case language
        case notificationEnabled = "notification_enabled"
        case notificationTime = "notification_time"
        case createdAt = "created_at"
        case lastActiveAt = "last_active_at"
    }
}

// MARK: - User State
enum UserState {
    case authenticated(User)
    case guest(String) // device ID
    case unauthenticated
    
    var isAuthenticated: Bool {
        if case .authenticated = self {
            return true
        }
        return false
    }
    
    var identifier: String {
        switch self {
        case .authenticated(let user):
            return user.id.uuidString
        case .guest(let deviceId):
            return deviceId
        case .unauthenticated:
            return UUID().uuidString
        }
    }
}

// MARK: - Birth Info
struct BirthInfo: Codable {
    let date: Date
    let time: String?
    let city: String
    let country: String
    let timezone: String
    
    var isValid: Bool {
        return !city.isEmpty && !country.isEmpty
    }
}
