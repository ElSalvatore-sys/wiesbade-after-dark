//
//  MockWalletPassService.swift
//  WiesbadenAfterDark
//
//  Mock implementation of wallet pass service for development
//

import Foundation

@MainActor
final class MockWalletPassService: WalletPassServiceProtocol {
    // MARK: - Properties

    static let shared = MockWalletPassService()

    private let networkDelay: TimeInterval = 1.0

    // In-memory storage for mock data
    private var passes: [WalletPass] = []

    private init() {
        print("✅ [MockWalletPassService] Initialized")
    }

    // MARK: - Pass Generation

    func generatePass(
        userId: UUID,
        venueId: UUID,
        venueName: String,
        membership: VenueMembership
    ) async throws -> WalletPass {
        print("📱 [WalletPass] Generating pass for \(venueName)")
        print("   User: \(userId.uuidString.prefix(8))...")
        print("   Membership tier: \(membership.tier.displayName)")
        print("   Points: \(membership.pointsBalance)")

        // Check if pass already exists
        if let existingPass = try await fetchPass(userId: userId, venueId: venueId) {
            print("ℹ️ [WalletPass] Pass already exists, returning existing")
            return existingPass
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        // Generate unique serial number
        let serial = "WAD-\(venueName.prefix(3).uppercased())-\(userId.uuidString.prefix(8).uppercased())"

        // Generate QR code data (JSON payload)
        let qrData = """
        {
            "userId": "\(userId.uuidString)",
            "venueId": "\(venueId.uuidString)",
            "serial": "\(serial)",
            "tier": "\(membership.tier.rawValue)",
            "points": \(membership.pointsBalance),
            "timestamp": \(Date().timeIntervalSince1970)
        }
        """

        // Generate NFC payload
        let nfcPayload = "wad://check-in/\(venueId.uuidString)/\(userId.uuidString)"

        // Generate authentication token
        let authToken = UUID().uuidString

        // Create wallet pass
        let pass = WalletPass(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            passTypeIdentifier: "pass.com.ea-solutions.wiesbaden-after-dark",
            serialNumber: serial,
            authenticationToken: authToken,
            qrCodeData: qrData,
            nfcPayload: nfcPayload,
            isAddedToWallet: false,
            lastUpdated: Date(),
            expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            memberTier: membership.tier.displayName,
            pointsBalance: membership.pointsBalance
        )

        // Store pass
        passes.append(pass)

        print("✅ [WalletPass] Pass generated successfully")
        print("   Serial: \(serial)")
        print("   QR Code: \(qrData.prefix(50))...")
        print("   NFC Payload: \(nfcPayload)")

        return pass
    }

    // MARK: - Fetch Operations

    func fetchUserPasses(userId: UUID) async throws -> [WalletPass] {
        print("📋 [WalletPass] Fetching passes for user")
        print("   User: \(userId.uuidString.prefix(8))...")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        let userPasses = passes.filter { $0.userId == userId }

        print("✅ [WalletPass] Found \(userPasses.count) passes")

        return userPasses
    }

    func fetchPass(userId: UUID, venueId: UUID) async throws -> WalletPass? {
        print("🔍 [WalletPass] Fetching pass for venue")

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(networkDelay * 1_000_000_000))

        let pass = passes.first { $0.userId == userId && $0.venueId == venueId }

        if let pass = pass {
            print("✅ [WalletPass] Pass found: \(pass.serialNumber)")
        } else {
            print("ℹ️ [WalletPass] No pass found for this venue")
        }

        return pass
    }

    // MARK: - Update Operations

    func markPassAsAdded(passId: UUID) async throws {
        print("✅ [WalletPass] Marking pass as added to wallet")
        print("   Pass ID: \(passId.uuidString.prefix(8))...")

        guard let index = passes.firstIndex(where: { $0.id == passId }) else {
            print("❌ [WalletPass] Pass not found")
            throw WalletPassError.passNotFound
        }

        passes[index].isAddedToWallet = true
        passes[index].lastUpdated = Date()

        print("✅ [WalletPass] Pass marked as added")
    }

    func updatePass(passId: UUID, membership: VenueMembership) async throws {
        print("🔄 [WalletPass] Updating pass with latest membership data")
        print("   Points: \(membership.pointsBalance)")
        print("   Tier: \(membership.tier.displayName)")

        guard let index = passes.firstIndex(where: { $0.id == passId }) else {
            print("❌ [WalletPass] Pass not found")
            throw WalletPassError.passNotFound
        }

        // Update pass with latest membership data
        passes[index].memberTier = membership.tier.displayName
        passes[index].pointsBalance = membership.pointsBalance
        passes[index].lastUpdated = Date()

        // Regenerate QR code with updated data
        let updatedQRData = """
        {
            "userId": "\(passes[index].userId.uuidString)",
            "venueId": "\(passes[index].venueId.uuidString)",
            "serial": "\(passes[index].serialNumber)",
            "tier": "\(membership.tier.rawValue)",
            "points": \(membership.pointsBalance),
            "timestamp": \(Date().timeIntervalSince1970)
        }
        """
        passes[index].qrCodeData = updatedQRData

        print("✅ [WalletPass] Pass updated successfully")
    }

    func addToWallet(_ pass: WalletPass) async throws {
        print("📲 [WalletPass] Adding pass to Apple Wallet (SIMULATED)")
        print("   Venue: \(pass.venueName)")
        print("   Serial: \(pass.serialNumber)")

        // Simulate Apple Wallet add animation delay
        try await Task.sleep(nanoseconds: UInt64(1.5 * 1_000_000_000))

        // In real implementation, this would use PKAddPassesViewController
        // For now, just mark as added
        try await markPassAsAdded(passId: pass.id)

        print("✅ [WalletPass] Pass added to wallet successfully!")
        print("   💡 In production: This would use PassKit framework")
        print("   💡 User would see Apple Wallet add animation")
    }

    func deletePass(passId: UUID) async throws {
        print("🗑️ [WalletPass] Deleting pass")

        guard let index = passes.firstIndex(where: { $0.id == passId }) else {
            print("❌ [WalletPass] Pass not found")
            throw WalletPassError.passNotFound
        }

        let deletedPass = passes.remove(at: index)

        print("✅ [WalletPass] Pass deleted: \(deletedPass.serialNumber)")
    }

    // MARK: - Mock Data

    /// Seeds mock wallet passes for testing
    func seedMockData(userId: UUID, venues: [Venue]) {
        print("🌱 [MockWalletPassService] Seeding mock passes...")

        for venue in venues.prefix(2) { // Add passes for first 2 venues
            let mockMembership = VenueMembership(
                userId: userId,
                venueId: venue.id,
                pointsBalance: Int.random(in: 100...1000),
                tier: MembershipTier.allCases.randomElement() ?? .bronze
            )

            Task {
                do {
                    let pass = try await generatePass(
                        userId: userId,
                        venueId: venue.id,
                        venueName: venue.name,
                        membership: mockMembership
                    )

                    // Randomly mark some as added to wallet
                    if Bool.random() {
                        try await markPassAsAdded(passId: pass.id)
                    }
                } catch {
                    print("❌ [MockWalletPassService] Error seeding pass: \(error)")
                }
            }
        }

        print("✅ [MockWalletPassService] Seeded passes for \(min(2, venues.count)) venues")
    }
}
