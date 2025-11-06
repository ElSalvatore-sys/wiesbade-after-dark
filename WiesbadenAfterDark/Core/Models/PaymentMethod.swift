//
//  PaymentMethod.swift
//  WiesbadenAfterDark
//
//  Payment method types and status enums
//

import Foundation

/// Payment method types
enum PaymentMethodType: String, Codable, CaseIterable {
    case card = "Card"
    case applePay = "Apple Pay"
    case googlePay = "Google Pay"
    case points = "Points"
    case combo = "Points + Card"

    var icon: String {
        switch self {
        case .card:
            return "creditcard.fill"
        case .applePay:
            return "apple.logo"
        case .googlePay:
            return "g.circle.fill"
        case .points:
            return "star.fill"
        case .combo:
            return "star.circle.fill"
        }
    }

    var displayName: String {
        return rawValue
    }
}

/// Payment status
enum PaymentStatus: String, Codable {
    case pending = "Pending"
    case processing = "Processing"
    case succeeded = "Succeeded"
    case failed = "Failed"
    case refunded = "Refunded"
    case partiallyRefunded = "Partially Refunded"

    var color: String {
        switch self {
        case .pending, .processing:
            return "warning"
        case .succeeded:
            return "success"
        case .failed:
            return "error"
        case .refunded, .partiallyRefunded:
            return "secondary"
        }
    }

    var icon: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .processing:
            return "arrow.triangle.2.circlepath"
        case .succeeded:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        case .refunded, .partiallyRefunded:
            return "arrow.uturn.left.circle.fill"
        }
    }
}
