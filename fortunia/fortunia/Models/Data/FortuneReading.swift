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
enum FortuneReadingType: String, CaseIterable, Hashable {
    case face = "face"
    case palm = "palm"
    case tarot = "tarot"
    case coffee = "coffee"
    
    var displayName: String {
        switch self {
        case .face: return NSLocalizedString("reading_type_face", comment: "Face Reading") // localized
        case .palm: return NSLocalizedString("reading_type_palm", comment: "Palm Reading") // localized
        case .tarot: return NSLocalizedString("reading_type_tarot", comment: "Tarot Reading") // localized
        case .coffee: return NSLocalizedString("reading_type_coffee", comment: "Coffee Reading") // localized
        }
    }
    
    var description: String {
        switch self {
        case .face: return NSLocalizedString("reading_type_face_desc", comment: "Discover your personality through facial features") // localized
        case .palm: return NSLocalizedString("reading_type_palm_desc", comment: "Read your life lines and destiny") // localized
        case .tarot: return NSLocalizedString("reading_type_tarot_desc", comment: "Get guidance from ancient tarot cards") // localized
        case .coffee: return NSLocalizedString("reading_type_coffee_desc", comment: "Interpret your future from coffee grounds") // localized
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
        case .chinese: return NSLocalizedString("cultural_origin_chinese", comment: "Chinese") // localized
        case .middleEastern: return NSLocalizedString("cultural_origin_middle_eastern", comment: "Middle Eastern") // localized
        case .european: return NSLocalizedString("cultural_origin_european", comment: "European") // localized
        }
    }
    
    var description: String {
        switch self {
        case .chinese: return NSLocalizedString("cultural_origin_chinese_desc", comment: "Ancient Chinese divination traditions") // localized
        case .middleEastern: return NSLocalizedString("cultural_origin_middle_eastern_desc", comment: "Middle Eastern mystical practices") // localized
        case .european: return NSLocalizedString("cultural_origin_european_desc", comment: "European fortune telling methods") // localized
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
    
    enum CodingKeys: String, CodingKey {
        case success
        case result
        case shareCardUrl = "share_card_url"
        case readingType = "reading_type"
        case culturalOrigin = "cultural_origin"
        case processingTime = "processing_time"
        case error
    }
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
