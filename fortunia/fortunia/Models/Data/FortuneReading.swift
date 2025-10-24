//
//  FortuneReading.swift
//  fortunia
//
//  Created by Can Soğancı on 24.10.2025.
//

import Foundation

// MARK: - Fortune Reading Model
struct FortuneReading: Codable, Identifiable {
    let id: UUID
    let userId: UUID?
    let readingType: String
    let culturalOrigin: String
    let imageUrl: String?
    let resultText: String
    let shareCardUrl: String?
    let isPremium: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case readingType = "reading_type"
        case culturalOrigin = "cultural_origin"
        case imageUrl = "image_url"
        case resultText = "result_text"
        case shareCardUrl = "share_card_url"
        case isPremium = "is_premium"
        case createdAt = "created_at"
    }
}

// MARK: - Fortune Reading Types
enum FortuneReadingType: String, CaseIterable {
    case face = "face"
    case palm = "palm"
    case tarot = "tarot"
    case coffee = "coffee"
    
    var displayName: String {
        switch self {
        case .face: return "Face Reading"
        case .palm: return "Palm Reading"
        case .tarot: return "Tarot Reading"
        case .coffee: return "Coffee Reading"
        }
    }
    
    var description: String {
        switch self {
        case .face: return "Discover your personality through facial features"
        case .palm: return "Read your life lines and destiny"
        case .tarot: return "Get guidance from ancient tarot cards"
        case .coffee: return "Interpret your future from coffee grounds"
        }
    }
    
    var icon: String {
        switch self {
        case .face: return "face.smiling"
        case .palm: return "hand.raised"
        case .tarot: return "sparkles"
        case .coffee: return "cup.and.saucer"
        }
    }
}

// MARK: - Cultural Origins
enum CulturalOrigin: String, CaseIterable {
    case chinese = "chinese"
    case middleEastern = "middle_eastern"
    case european = "european"
    
    var displayName: String {
        switch self {
        case .chinese: return "Chinese"
        case .middleEastern: return "Middle Eastern"
        case .european: return "European"
        }
    }
    
    var description: String {
        switch self {
        case .chinese: return "Ancient Chinese divination traditions"
        case .middleEastern: return "Middle Eastern mystical practices"
        case .european: return "European fortune telling methods"
        }
    }
}

// MARK: - Fortune Result
struct FortuneResult: Codable {
    let success: Bool
    let result: String
    let shareCardUrl: String?
    let readingType: String
    let culturalOrigin: String
    let processingTime: Double?
    let error: String?
}

// MARK: - Quota Info
struct QuotaInfo: Codable {
    let quotaUsed: Int
    let quotaLimit: Int
    let quotaRemaining: Int
    let isPremium: Bool
    
    enum CodingKeys: String, CodingKey {
        case quotaUsed = "quota_used"
        case quotaLimit = "quota_limit"
        case quotaRemaining = "quota_remaining"
        case isPremium = "is_premium"
    }
}
