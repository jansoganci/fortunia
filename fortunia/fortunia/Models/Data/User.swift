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
    let onboardingCompleted: Bool
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
        case onboardingCompleted = "onboarding_completed"
        case timezone
        case language
        case notificationEnabled = "notification_enabled"
        case notificationTime = "notification_time"
        case createdAt = "created_at"
        case lastActiveAt = "last_active_at"
    }
    
    // Custom decoder to handle date format flexibility
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        
        // Handle flexible date parsing for birthDate
        var parsedBirthDate: Date? = nil
        
        if let birthDateString = try? container.decodeIfPresent(String.self, forKey: .birthDate) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            
            // Try ISO format first
            parsedBirthDate = dateFormatter.date(from: birthDateString) ?? ISO8601DateFormatter().date(from: birthDateString)
            
            // If that fails, try date-only format
            if parsedBirthDate == nil {
                let dateOnlyFormatter = DateFormatter()
                dateOnlyFormatter.dateFormat = "yyyy-MM-dd"
                dateOnlyFormatter.timeZone = TimeZone(identifier: "UTC")
                parsedBirthDate = dateOnlyFormatter.date(from: birthDateString)
            }
        } else if let birthDateValue = try? container.decodeIfPresent(Date.self, forKey: .birthDate) {
            parsedBirthDate = birthDateValue
        }
        
        birthDate = parsedBirthDate
        
        birthTime = try container.decodeIfPresent(String.self, forKey: .birthTime)
        birthCity = try container.decodeIfPresent(String.self, forKey: .birthCity)
        birthCountry = try container.decodeIfPresent(String.self, forKey: .birthCountry)
        onboardingCompleted = try container.decode(Bool.self, forKey: .onboardingCompleted)
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone) ?? "UTC"
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? "en"
        notificationEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationEnabled) ?? false
        notificationTime = try container.decodeIfPresent(String.self, forKey: .notificationTime)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        lastActiveAt = try container.decodeIfPresent(Date.self, forKey: .lastActiveAt) ?? Date()
    }
    
    // Implement encoder to handle date format flexibility when encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(birthDate, forKey: .birthDate)
        try container.encodeIfPresent(birthTime, forKey: .birthTime)
        try container.encodeIfPresent(birthCity, forKey: .birthCity)
        try container.encodeIfPresent(birthCountry, forKey: .birthCountry)
        try container.encode(onboardingCompleted, forKey: .onboardingCompleted)
        try container.encode(timezone, forKey: .timezone)
        try container.encode(language, forKey: .language)
        try container.encode(notificationEnabled, forKey: .notificationEnabled)
        try container.encodeIfPresent(notificationTime, forKey: .notificationTime)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(lastActiveAt, forKey: .lastActiveAt)
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
