//
//  PointTransaction.swift
//  WiesbadenAfterDark
//
//  Detailed point earning and spending transaction history
//

import Foundation
import SwiftData

/// Transaction type (earning or spending points)
enum TransactionType: String, Codable, CaseIterable {
    case earn = "Earned"
    case redeem = "Redeemed"
    case bonus = "Bonus"
    case refund = "Refund"

    var icon: String {
        switch self {
        case .earn: return "arrow.up.circle.fill"
        case .redeem: return "arrow.down.circle.fill"
        case .bonus: return "gift.fill"
        case .refund: return "arrow.uturn.left.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .earn, .bonus, .refund: return "success"
        case .redeem: return "error"
        }
    }
}

/// Transaction source (what caused the transaction)
enum TransactionSource: String, Codable, CaseIterable {
    case checkIn = "Check-In"
    case rewardRedemption = "Reward"
    case streakBonus = "Streak Bonus"
    case eventBonus = "Event Bonus"
    case referralBonus = "Referral"
    case promotionalBonus = "Promotion"
    case refund = "Refund"

    var icon: String {
        switch self {
        case .checkIn: return "location.fill"
        case .rewardRedemption: return "gift"
        case .streakBonus: return "flame.fill"
        case .eventBonus: return "calendar"
        case .referralBonus: return "person.2.fill"
        case .promotionalBonus: return "megaphone.fill"
        case .refund: return "arrow.uturn.left"
        }
    }
}

/// Represents a point transaction (earning or spending)
@Model
final class PointTransaction: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID

    // User & Venue
    var userId: UUID
    var venueId: UUID
    var venueName: String

    // Transaction details
    var type: TransactionType
    var source: TransactionSource
    var amount: Int // Positive for earning, negative for spending
    var transactionDescription: String

    // Balance tracking
    var balanceBefore: Int
    var balanceAfter: Int

    // Related entities
    var checkInId: UUID? // If from check-in
    var rewardId: UUID? // If from reward redemption
    var eventId: UUID? // If from event-related bonus

    var timestamp: Date
    var createdAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        venueId: UUID,
        venueName: String,
        type: TransactionType,
        source: TransactionSource,
        amount: Int,
        transactionDescription: String,
        balanceBefore: Int,
        balanceAfter: Int,
        checkInId: UUID? = nil,
        rewardId: UUID? = nil,
        eventId: UUID? = nil,
        timestamp: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.venueName = venueName
        self.type = type
        self.source = source
        self.amount = amount
        self.transactionDescription = transactionDescription
        self.balanceBefore = balanceBefore
        self.balanceAfter = balanceAfter
        self.checkInId = checkInId
        self.rewardId = rewardId
        self.eventId = eventId
        self.timestamp = timestamp
        self.createdAt = createdAt
    }
}

// MARK: - Computed Properties
extension PointTransaction {
    /// Formatted amount with sign
    var formattedAmount: String {
        let sign = amount >= 0 ? "+" : ""
        return "\(sign)\(amount)"
    }

    /// Formatted timestamp
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    /// Time ago format
    var timeAgo: String {
        let now = Date()
        let seconds = now.timeIntervalSince(timestamp)

        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "\(hours)h ago"
        } else if seconds < 604800 {
            let days = Int(seconds / 86400)
            return "\(days)d ago"
        } else {
            return formattedTime
        }
    }

    /// Short description for compact display
    var shortDescription: String {
        switch source {
        case .checkIn:
            return "Check-in at \(venueName)"
        case .rewardRedemption:
            return "Redeemed reward"
        case .streakBonus:
            return "Streak bonus"
        case .eventBonus:
            return "Event bonus"
        case .referralBonus:
            return "Referral bonus"
        case .promotionalBonus:
            return "Promotional bonus"
        case .refund:
            return "Refund"
        }
    }
}

// MARK: - Mock Data
extension PointTransaction {
    /// Creates a mock transaction for testing
    static func mock(
        userId: UUID,
        venueId: UUID,
        venueName: String,
        type: TransactionType,
        hoursAgo: Double = 2
    ) -> PointTransaction {
        let timestamp = Date().addingTimeInterval(-hoursAgo * 3600)
        let amount: Int
        let source: TransactionSource
        let description: String

        switch type {
        case .earn:
            amount = Int.random(in: 50...200)
            source = .checkIn
            description = "Check-in at \(venueName)"
        case .redeem:
            amount = -Int.random(in: 100...500)
            source = .rewardRedemption
            description = "Redeemed reward at \(venueName)"
        case .bonus:
            amount = Int.random(in: 25...100)
            source = .streakBonus
            description = "7-day streak bonus"
        case .refund:
            amount = Int.random(in: 50...200)
            source = .refund
            description = "Refund for cancelled reward"
        }

        let balanceBefore = Int.random(in: 500...1500)
        let balanceAfter = balanceBefore + amount

        return PointTransaction(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            type: type,
            source: source,
            amount: amount,
            transactionDescription: description,
            balanceBefore: balanceBefore,
            balanceAfter: balanceAfter,
            timestamp: timestamp
        )
    }

    /// Creates array of mock transactions
    static func mockHistory(
        userId: UUID,
        venueId: UUID,
        venueName: String,
        count: Int = 10
    ) -> [PointTransaction] {
        let types: [TransactionType] = [.earn, .earn, .earn, .redeem, .bonus]
        return (0..<count).map { index in
            mock(
                userId: userId,
                venueId: venueId,
                venueName: venueName,
                type: types.randomElement() ?? .earn,
                hoursAgo: Double(index * 12 + Int.random(in: 1...6))
            )
        }
    }
}
