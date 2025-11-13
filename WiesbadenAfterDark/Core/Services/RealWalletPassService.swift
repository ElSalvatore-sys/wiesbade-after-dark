//
//  RealWalletPassService.swift
//  WiesbadenAfterDark
//
//  Production implementation of wallet pass service with PassKit integration
//

import Foundation
import PassKit
import SwiftData

@MainActor
final class RealWalletPassService: WalletPassServiceProtocol {
    // MARK: - Properties

    static let shared = RealWalletPassService()

    private let baseURL = "https://wiesbade-after-dark-production.up.railway.app"
    private let passTypeIdentifier = "pass.com.wiesbaden.afterdark"
    private let organizationName = "Wiesbaden After Dark"

    private let urlSession: URLSession
    private var modelContext: ModelContext?

    // MARK: - Initialization

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.urlSession = URLSession(configuration: configuration)

        print("✅ [RealWalletPassService] Initialized")
    }

    /// Sets the SwiftData model context for persistence
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        print("✅ [RealWalletPassService] Model context set")
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

        // Check if pass already exists locally
        if let existingPass = try await fetchPass(userId: userId, venueId: venueId) {
            print("ℹ️ [WalletPass] Pass already exists locally")
            return existingPass
        }

        // Generate pass via backend API
        let pass = try await generatePassFromBackend(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            membership: membership
        )

        // Save to local database
        if let context = modelContext {
            context.insert(pass)
            try context.save()
            print("✅ [WalletPass] Pass saved to local database")
        }

        print("✅ [WalletPass] Pass generated successfully")
        print("   Serial: \(pass.serialNumber)")
        print("   NFC Payload: \(pass.nfcPayload)")

        return pass
    }

    /// Generates pass through backend API
    private func generatePassFromBackend(
        userId: UUID,
        venueId: UUID,
        venueName: String,
        membership: VenueMembership
    ) async throws -> WalletPass {
        // Prepare API request
        guard let url = URL(string: "\(baseURL)/api/v1/wallet-passes/generate") else {
            throw WalletPassError.generationFailed
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Request body
        let requestBody: [String: Any] = [
            "userId": userId.uuidString,
            "venueId": venueId.uuidString,
            "passType": "membership",
            "memberTier": membership.tier.rawValue,
            "pointsBalance": membership.pointsBalance
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Make API call
        print("🌐 [WalletPass] Calling backend API...")
        let (data, response) = try await urlSession.data(for: request)

        // Check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WalletPassError.networkError
        }

        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            print("❌ [WalletPass] Backend API error: \(httpResponse.statusCode)")
            throw WalletPassError.generationFailed
        }

        // Parse response
        let decoder = JSONDecoder()
        let passResponse = try decoder.decode(PassGenerationResponse.self, from: data)

        print("✅ [WalletPass] Backend API response received")
        print("   Serial: \(passResponse.serialNumber)")

        // Generate authentication token
        let authToken = passResponse.authenticationToken ?? UUID().uuidString

        // Generate NFC payload with security token
        let securityToken = generateSecurityToken()
        let nfcPayload = "wad://check-in/\(userId.uuidString)/\(venueId.uuidString)/\(securityToken)"

        // Generate QR code data
        let qrData = """
        {
            "userId": "\(userId.uuidString)",
            "venueId": "\(venueId.uuidString)",
            "serial": "\(passResponse.serialNumber)",
            "tier": "\(membership.tier.rawValue)",
            "points": \(membership.pointsBalance),
            "timestamp": \(Date().timeIntervalSince1970)
        }
        """

        // Create WalletPass model
        let pass = WalletPass(
            userId: userId,
            venueId: venueId,
            venueName: venueName,
            passTypeIdentifier: passTypeIdentifier,
            serialNumber: passResponse.serialNumber,
            authenticationToken: authToken,
            qrCodeData: qrData,
            nfcPayload: nfcPayload,
            isAddedToWallet: false,
            lastUpdated: Date(),
            expiresAt: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
            memberTier: membership.tier.displayName,
            pointsBalance: membership.pointsBalance
        )

        return pass
    }

    // MARK: - Fetch Operations

    func fetchUserPasses(userId: UUID) async throws -> [WalletPass] {
        print("📋 [WalletPass] Fetching passes for user")
        print("   User: \(userId.uuidString.prefix(8))...")

        guard let context = modelContext else {
            print("⚠️ [WalletPass] No model context available")
            return []
        }

        // Fetch from local database
        let descriptor = FetchDescriptor<WalletPass>(
            predicate: #Predicate { pass in
                pass.userId == userId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        let passes = try context.fetch(descriptor)
        print("✅ [WalletPass] Found \(passes.count) passes")

        return passes
    }

    func fetchPass(userId: UUID, venueId: UUID) async throws -> WalletPass? {
        print("🔍 [WalletPass] Fetching pass for venue")

        guard let context = modelContext else {
            print("⚠️ [WalletPass] No model context available")
            return nil
        }

        // Fetch from local database
        let descriptor = FetchDescriptor<WalletPass>(
            predicate: #Predicate { pass in
                pass.userId == userId && pass.venueId == venueId
            }
        )

        let passes = try context.fetch(descriptor)
        let pass = passes.first

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

        guard let context = modelContext else {
            throw WalletPassError.passNotFound
        }

        // Find pass
        let descriptor = FetchDescriptor<WalletPass>(
            predicate: #Predicate { pass in
                pass.id == passId
            }
        )

        let passes = try context.fetch(descriptor)
        guard let pass = passes.first else {
            print("❌ [WalletPass] Pass not found")
            throw WalletPassError.passNotFound
        }

        // Update pass
        pass.isAddedToWallet = true
        pass.lastUpdated = Date()

        try context.save()
        print("✅ [WalletPass] Pass marked as added")
    }

    func updatePass(passId: UUID, membership: VenueMembership) async throws {
        print("🔄 [WalletPass] Updating pass with latest membership data")
        print("   Points: \(membership.pointsBalance)")
        print("   Tier: \(membership.tier.displayName)")

        guard let context = modelContext else {
            throw WalletPassError.passNotFound
        }

        // Find pass
        let descriptor = FetchDescriptor<WalletPass>(
            predicate: #Predicate { pass in
                pass.id == passId
            }
        )

        let passes = try context.fetch(descriptor)
        guard let pass = passes.first else {
            print("❌ [WalletPass] Pass not found")
            throw WalletPassError.passNotFound
        }

        // Update pass with latest membership data
        pass.memberTier = membership.tier.displayName
        pass.pointsBalance = membership.pointsBalance
        pass.lastUpdated = Date()

        // Regenerate QR code with updated data
        let updatedQRData = """
        {
            "userId": "\(pass.userId.uuidString)",
            "venueId": "\(pass.venueId.uuidString)",
            "serial": "\(pass.serialNumber)",
            "tier": "\(membership.tier.rawValue)",
            "points": \(membership.pointsBalance),
            "timestamp": \(Date().timeIntervalSince1970)
        }
        """
        pass.qrCodeData = updatedQRData

        try context.save()

        // If pass is in wallet, trigger update notification
        if pass.isAddedToWallet {
            try await sendPassUpdateNotification(pass: pass)
        }

        print("✅ [WalletPass] Pass updated successfully")
    }

    /// Sends update notification to Apple Wallet
    private func sendPassUpdateNotification(pass: WalletPass) async throws {
        print("🔔 [WalletPass] Sending pass update notification to Apple")

        // In a production environment, this would:
        // 1. Send a push notification to Apple's pass update service
        // 2. Apple would then notify the device that the pass has been updated
        // 3. The device would download the updated pass from your server

        // For now, we'll simulate this with a backend API call
        guard let url = URL(string: "\(baseURL)/api/v1/wallet-passes/\(pass.serialNumber)/notify") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(pass.authenticationToken)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "serialNumber": pass.serialNumber,
            "passTypeIdentifier": pass.passTypeIdentifier
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (_, response) = try await urlSession.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ [WalletPass] Update notification sent successfully")
            } else {
                print("⚠️ [WalletPass] Failed to send update notification")
            }
        } catch {
            print("⚠️ [WalletPass] Error sending update notification: \(error)")
        }
    }

    // MARK: - Apple Wallet Integration

    func addToWallet(_ pass: WalletPass) async throws {
        print("📲 [WalletPass] Adding pass to Apple Wallet")
        print("   Venue: \(pass.venueName)")
        print("   Serial: \(pass.serialNumber)")

        // Check if PassKit is available
        guard PKPassLibrary.isPassLibraryAvailable() else {
            print("❌ [WalletPass] PassKit not available on this device")
            throw WalletPassError.generationFailed
        }

        // Download .pkpass file from backend
        let pkpassData = try await downloadPKPassFile(pass: pass)

        // Create PKPass object
        guard let pkPass = try? PKPass(data: pkpassData) else {
            print("❌ [WalletPass] Failed to create PKPass object")
            throw WalletPassError.generationFailed
        }

        // Check if pass is already in wallet
        let passLibrary = PKPassLibrary()
        if passLibrary.containsPass(pkPass) {
            print("ℹ️ [WalletPass] Pass already in Apple Wallet")
            try await markPassAsAdded(passId: pass.id)
            return
        }

        // Present add pass view controller
        // Note: This needs to be called from a view controller context
        // The actual presentation happens in the view layer
        print("✅ [WalletPass] PKPass created, ready to present to user")

        // Mark as added (actual addition happens in UI layer)
        try await markPassAsAdded(passId: pass.id)
    }

    /// Downloads .pkpass file from backend
    private func downloadPKPassFile(pass: WalletPass) async throws -> Data {
        print("📥 [WalletPass] Downloading .pkpass file from backend")

        guard let url = URL(string: "\(baseURL)/api/v1/wallet-passes/\(pass.serialNumber)/download") else {
            throw WalletPassError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(pass.authenticationToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await urlSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WalletPassError.networkError
        }

        guard httpResponse.statusCode == 200 else {
            print("❌ [WalletPass] Failed to download .pkpass file: \(httpResponse.statusCode)")
            throw WalletPassError.networkError
        }

        print("✅ [WalletPass] .pkpass file downloaded successfully (\(data.count) bytes)")
        return data
    }

    /// Presents Apple Wallet add pass view controller
    /// - Returns: PKPass object ready to be presented
    func createPKPass(from walletPass: WalletPass) async throws -> PKPass {
        let pkpassData = try await downloadPKPassFile(pass: walletPass)

        guard let pkPass = try? PKPass(data: pkpassData) else {
            throw WalletPassError.generationFailed
        }

        return pkPass
    }

    // MARK: - Delete Operations

    func deletePass(passId: UUID) async throws {
        print("🗑️ [WalletPass] Deleting pass")

        guard let context = modelContext else {
            throw WalletPassError.passNotFound
        }

        // Find pass
        let descriptor = FetchDescriptor<WalletPass>(
            predicate: #Predicate { pass in
                pass.id == passId
            }
        )

        let passes = try context.fetch(descriptor)
        guard let pass = passes.first else {
            print("❌ [WalletPass] Pass not found")
            throw WalletPassError.passNotFound
        }

        // Delete from backend (optional, for cleanup)
        try await deletePassFromBackend(serialNumber: pass.serialNumber, authToken: pass.authenticationToken)

        // Delete from local database
        context.delete(pass)
        try context.save()

        print("✅ [WalletPass] Pass deleted: \(pass.serialNumber)")
    }

    /// Deletes pass from backend
    private func deletePassFromBackend(serialNumber: String, authToken: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/v1/wallet-passes/\(serialNumber)") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await urlSession.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("✅ [WalletPass] Pass deleted from backend")
            }
        } catch {
            print("⚠️ [WalletPass] Failed to delete pass from backend: \(error)")
            // Continue anyway - local deletion is more important
        }
    }

    // MARK: - Helper Methods

    /// Generates a secure token for NFC payload
    private func generateSecurityToken() -> String {
        let tokenData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        return tokenData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Checks if a pass can be added to wallet
    func canAddPassToWallet(pass: WalletPass) -> Bool {
        guard PKPassLibrary.isPassLibraryAvailable() else {
            return false
        }

        // Check if pass is expired
        if pass.isExpired {
            return false
        }

        // Check if already in wallet
        if pass.isAddedToWallet {
            return false
        }

        return true
    }
}

// MARK: - API Response Models

/// Response from pass generation API
private struct PassGenerationResponse: Codable {
    let passUrl: String
    let serialNumber: String
    let nfcPayload: String?
    let authenticationToken: String?
}

// MARK: - PassKit Extension

extension PKPassLibrary {
    /// Checks if a pass is already in the wallet
    func containsPass(_ pass: PKPass) -> Bool {
        return self.containsPass(pass)
    }
}
