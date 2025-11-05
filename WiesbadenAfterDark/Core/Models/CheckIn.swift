//
//  CheckIn.swift
//  WiesbadenAfterDark
//
//  Check-in transaction record with points and streak tracking
//

import Foundation
import SwiftData

/// Check-in method types
enum CheckInMethod: String, Codable, CaseIterable {
    case nfc = "NFC"
    case qr = "QR Code"
    case manual = "Manual"

    var icon: String {
        switch self {
        case .nfc: return "wave.3.right"
        case .qr: return "qrcode"
        case .manual: return "hand.tap"
        }
    }

    var displayName: String { rawValue }
}

/// Represents a venue check-in transaction
@Model
final class CheckIn: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID

    // User & Venue
    var userId: UUID
    var venueId: UUID
    var venueName: String

    // Check-in details
    var checkInTime: Date
    var checkInMethod: CheckInMethod
    var deviceId: String?

    // Points awarded
    var pointsEarned: Int
    var basePoints: Int
    var pointsMultiplier: Decimal
    var eventId: UUID? // Optional: if checking in to specific event
    var eventName: String?

    // Streak tracking
    var streakDay: Int // Day 1, 2, 3... of consecutive streak
    var isStreakBonus: Bool
    var streakMultiplier: Decimal

    // Additional data
    var metadata: [String: String] // Extra data (e.g., location, weather, etc.)
    var createdAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        venueId: UUID,
        venueName: String,
        checkInTime: Date = Date(),
        checkInMethod: CheckInMethod,
        deviceId: String? = nil,
        pointsEarned: Int,
        basePoints: Int = 50,
        pointsMultiplier: Decimal = 1.0,
        eventId: UUID? = nil,
        eventName: String? = nil,
        streakDay: Int = 1,
        isStreakBonus: Bool = false,
        streakMultiplier: Decimal = 1.0,
        metadata: [String: String] = [:],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.venueName = venueName
        self.checkInTime = checkInTime
        self.checkInMethod = checkInMethod
        self.deviceId = deviceId
        self.pointsEarned = pointsEarned
        self.basePoints = basePoints
        self.pointsMultiplier = pointsMultiplier
        self.eventId = eventId
        self.eventName = eventName
        self.streakDay = streakDay
        self.isStreakBonus = isStreakBonus
        self.streakMultiplier = streakMultiplier
        self.metadata = metadata
        self.createdAt = createdAt
    }
}

// MARK: - Computed Properties
extension CheckIn {
    /// Formatted check-in time
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: checkInTime)
    }

    /// Short time ago format (e.g., "2 hours ago")
    var timeAgo: String {
        let now = Date()
        let seconds = now.timeIntervalSince(checkInTime)

        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if seconds < 604800 {
            let days = Int(seconds / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else {
            return formattedTime
        }
    }

    /// Points breakdown text
    var pointsBreakdown: String {
        var parts: [String] = []
        parts.append("Base: \(basePoints) pts")

        if pointsMultiplier > 1.0 {
            let multiplierValue = NSDecimalNumber(decimal: pointsMultiplier).doubleValue
            parts.append("Event: ×\(String(format: "%.1f", multiplierValue))")
        }

        if streakMultiplier > 1.0 {
            let streakValue = NSDecimalNumber(decimal: streakMultiplier).doubleValue
            parts.append("Streak: ×\(String(format: "%.1f", streakValue))")
        }

        return parts.joined(separator: " • ")
    }

    /// Streak display text
    var streakText: String? {
        guard streakDay > 1 else { return nil }
        return "🔥 Day \(streakDay) Streak"
    }
}

// MARK: - Mock Data
extension CheckIn {
    /// Creates mock check-in for testing
    static func mock(
        userId: UUID = UUID(),
        venueId: UUID = UUID(),
        venueName: String = "Mock Venue",
        hoursAgo: Double = 2
    ) -> CheckIn {
        let checkInTime = Date().addingTimeInterval(-hoursAgo * 3600)
        let methods: [CheckInMethod] = [.nfc, .qr, .manual]
        let method = methods.randomElement() ?? .nfc

        let streakDay = Int.random(in: 1...7)
        let streakMultiplier: Decimal = {
            switch streakDay {
            case 1: return 1.0
            case 2: return 1.2
            case 3: return 1.5
            case 4: return 2.0
            default: return 2.5
            }
        }()

        let basePoints = 50
        let eventMultiplier: Decimal = Bool.random() ? 1.5 : 1.0
        let totalPoints = Int(Double(basePoints) * NSDecimalNumber(decimal: eventMultiplier * streakMultiplier).doubleValue)

        return CheckIn(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            checkInTime: checkInTime,
            checkInMethod: method,
            pointsEarned: totalPoints,
            basePoints: basePoints,
            pointsMultiplier: eventMultiplier,
            eventName: eventMultiplier > 1.0 ? "Friday Night Fever" : nil,
            streakDay: streakDay,
            isStreakBonus: streakDay > 1,
            streakMultiplier: streakMultiplier
        )
    }

    /// Creates array of mock check-ins
    static func mockHistory(userId: UUID, venueId: UUID, venueName: String, count: Int = 5) -> [CheckIn] {
        return (0..<count).map { index in
            mock(
                userId: userId,
                venueId: venueId,
                venueName: venueName,
                hoursAgo: Double(index * 24 + Int.random(in: 1...12))
            )
        }
    }
}
