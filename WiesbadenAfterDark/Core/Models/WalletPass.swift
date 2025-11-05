//
//  WalletPass.swift
//  WiesbadenAfterDark
//
//  Apple Wallet pass model for venue memberships
//

import Foundation
import SwiftData

/// Represents an Apple Wallet pass for a venue membership
@Model
final class WalletPass: @unchecked Sendable {
    // MARK: - Properties

    @Attribute(.unique) var id: UUID

    // User & Venue
    var userId: UUID
    var venueId: UUID
    var venueName: String
    var venueLogoURL: String?

    // Pass identification
    var passTypeIdentifier: String // Apple Pass Type ID
    var serialNumber: String // Unique serial number for this pass
    var authenticationToken: String // Token for pass updates

    // Pass content
    var qrCodeData: String // QR code payload (user/venue ID encoded)
    var nfcPayload: String // NFC tag payload for check-ins

    // Pass status
    var isAddedToWallet: Bool
    var lastUpdated: Date
    var expiresAt: Date?

    // Membership details (cached for pass display)
    var memberTier: String
    var pointsBalance: Int

    var createdAt: Date

    // MARK: - Initialization

    init(
        id: UUID = UUID(),
        userId: UUID,
        venueId: UUID,
        venueName: String,
        venueLogoURL: String? = nil,
        passTypeIdentifier: String,
        serialNumber: String,
        authenticationToken: String,
        qrCodeData: String,
        nfcPayload: String,
        isAddedToWallet: Bool = false,
        lastUpdated: Date = Date(),
        expiresAt: Date? = nil,
        memberTier: String = "Bronze",
        pointsBalance: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.venueId = venueId
        self.venueName = venueName
        self.venueLogoURL = venueLogoURL
        self.passTypeIdentifier = passTypeIdentifier
        self.serialNumber = serialNumber
        self.authenticationToken = authenticationToken
        self.qrCodeData = qrCodeData
        self.nfcPayload = nfcPayload
        self.isAddedToWallet = isAddedToWallet
        self.lastUpdated = lastUpdated
        self.expiresAt = expiresAt
        self.memberTier = memberTier
        self.pointsBalance = pointsBalance
        self.createdAt = createdAt
    }
}

// MARK: - Computed Properties
extension WalletPass {
    /// Pass status display text
    var statusText: String {
        if isAddedToWallet {
            return "Added to Wallet"
        } else {
            return "Not Added"
        }
    }

    /// Status color
    var statusColor: String {
        isAddedToWallet ? "success" : "textSecondary"
    }

    /// Is pass expired?
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false }
        return Date() > expiresAt
    }

    /// Formatted expiration date
    var formattedExpirationDate: String? {
        guard let expiresAt = expiresAt else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: expiresAt)
    }

    /// Last updated time ago
    var lastUpdatedText: String {
        let now = Date()
        let seconds = now.timeIntervalSince(lastUpdated)

        if seconds < 60 {
            return "Updated just now"
        } else if seconds < 3600 {
            let minutes = Int(seconds / 60)
            return "Updated \(minutes)m ago"
        } else if seconds < 86400 {
            let hours = Int(seconds / 3600)
            return "Updated \(hours)h ago"
        } else {
            let days = Int(seconds / 86400)
            return "Updated \(days)d ago"
        }
    }
}

// MARK: - Mock Data
extension WalletPass {
    /// Creates a mock wallet pass for testing
    static func mock(
        userId: UUID = UUID(),
        venueId: UUID = UUID(),
        venueName: String = "Mock Venue",
        isAdded: Bool = false
    ) -> WalletPass {
        // Generate unique serial number
        let serial = "WAD-\(venueName.prefix(3).uppercased())-\(userId.uuidString.prefix(8))"

        // Generate QR code data (JSON encoded)
        let qrData = """
        {
            "userId": "\(userId.uuidString)",
            "venueId": "\(venueId.uuidString)",
            "serial": "\(serial)",
            "timestamp": "\(Date().timeIntervalSince1970)"
        }
        """

        // Generate NFC payload
        let nfcPayload = "wad://check-in/\(venueId.uuidString)/\(userId.uuidString)"

        // Generate authentication token
        let authToken = UUID().uuidString

        return WalletPass(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            passTypeIdentifier: "pass.com.ea-solutions.wiesbaden-after-dark",
            serialNumber: serial,
            authenticationToken: authToken,
            qrCodeData: qrData,
            nfcPayload: nfcPayload,
            isAddedToWallet: isAdded,
            lastUpdated: Date().addingTimeInterval(-Double.random(in: 3600...86400)),
            expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            memberTier: ["Bronze", "Silver", "Gold", "Platinum"].randomElement() ?? "Bronze",
            pointsBalance: Int.random(in: 100...2000)
        )
    }

    /// Creates array of mock wallet passes
    static func mockPasses(userId: UUID, venues: [Venue]) -> [WalletPass] {
        return venues.map { venue in
            mock(
                userId: userId,
                venueId: venue.id,
                venueName: venue.name,
                isAdded: Bool.random()
            )
        }
    }
}
