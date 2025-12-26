//
//  RealNFCReaderService.swift
//  WiesbadenAfterDark
//
//  Created by Claude Code on 26.12.2025.
//  Real NFC implementation for venue check-ins
//

import Foundation
import CoreNFC
import Combine

/// Real NFC Reader Service using CoreNFC framework
/// Reads NDEF tags for venue check-ins
@MainActor
final class RealNFCReaderService: NSObject, ObservableObject {

    // MARK: - Published Properties
    @Published var isScanning = false
    @Published var lastScannedVenueId: String?
    @Published var lastError: NFCError?
    @Published var scanStatus: ScanStatus = .idle

    // MARK: - Types
    enum ScanStatus: Equatable {
        case idle
        case scanning
        case success(venueId: String)
        case error(NFCError)
    }

    enum NFCError: Error, LocalizedError, Equatable {
        case notSupported
        case sessionInvalidated
        case tagReadFailed
        case invalidPayload
        case noVenueIdFound
        case userCancelled
        case unknown(String)

        var errorDescription: String? {
            switch self {
            case .notSupported:
                return "NFC wird auf diesem Gerät nicht unterstützt"
            case .sessionInvalidated:
                return "NFC-Sitzung wurde beendet"
            case .tagReadFailed:
                return "Tag konnte nicht gelesen werden"
            case .invalidPayload:
                return "Ungültige Tag-Daten"
            case .noVenueIdFound:
                return "Keine Venue-ID auf dem Tag gefunden"
            case .userCancelled:
                return "Scan abgebrochen"
            case .unknown(let message):
                return message
            }
        }

        static func == (lhs: NFCError, rhs: NFCError) -> Bool {
            switch (lhs, rhs) {
            case (.notSupported, .notSupported),
                 (.sessionInvalidated, .sessionInvalidated),
                 (.tagReadFailed, .tagReadFailed),
                 (.invalidPayload, .invalidPayload),
                 (.noVenueIdFound, .noVenueIdFound),
                 (.userCancelled, .userCancelled):
                return true
            case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
                return lhsMsg == rhsMsg
            default:
                return false
            }
        }
    }

    // MARK: - Private Properties
    private var nfcSession: NFCNDEFReaderSession?
    private var scanContinuation: CheckedContinuation<String, Error>?

    // MARK: - Public Methods

    /// Check if NFC is available on this device
    var isNFCAvailable: Bool {
        NFCNDEFReaderSession.readingAvailable
    }

    /// Start scanning for NFC tags
    /// Returns the venue ID from the scanned tag
    func startScanning() async throws -> String {
        guard isNFCAvailable else {
            throw NFCError.notSupported
        }

        // Cancel any existing session
        nfcSession?.invalidate()

        return try await withCheckedThrowingContinuation { continuation in
            self.scanContinuation = continuation

            // Create NFC session
            nfcSession = NFCNDEFReaderSession(
                delegate: self,
                queue: DispatchQueue.main,
                invalidateAfterFirstRead: true
            )

            // Configure alert message
            nfcSession?.alertMessage = "Halte dein iPhone an den NFC-Tag zum Einchecken"

            // Start scanning
            isScanning = true
            scanStatus = .scanning
            nfcSession?.begin()
        }
    }

    /// Stop scanning
    func stopScanning() {
        nfcSession?.invalidate()
        nfcSession = nil
        isScanning = false
        scanStatus = .idle
    }

    // MARK: - Private Helpers

    private func parseVenueId(from payload: NFCNDEFPayload) -> String? {
        // Try to parse as URI
        if let uri = payload.wellKnownTypeURIPayload()?.absoluteString {
            // Expected format: wad://checkin/{venueId}
            // or https://wiesbadenafterdark.de/checkin/{venueId}
            if let venueId = extractVenueId(from: uri) {
                return venueId
            }
        }

        // Try to parse as text
        if let text = String(data: payload.payload, encoding: .utf8) {
            // Check if it's a UUID or venue ID
            if let venueId = extractVenueId(from: text) {
                return venueId
            }

            // Maybe it's just the venue ID directly
            let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if UUID(uuidString: cleaned) != nil {
                return cleaned
            }
        }

        return nil
    }

    private func extractVenueId(from urlString: String) -> String? {
        // Handle wad://checkin/{venueId}
        if urlString.hasPrefix("wad://checkin/") {
            return String(urlString.dropFirst("wad://checkin/".count))
        }

        // Handle https://wiesbadenafterdark.de/checkin/{venueId}
        if let url = URL(string: urlString),
           url.pathComponents.contains("checkin"),
           let venueIdIndex = url.pathComponents.firstIndex(of: "checkin"),
           venueIdIndex + 1 < url.pathComponents.count {
            return url.pathComponents[venueIdIndex + 1]
        }

        // Handle wiesbaden-after-dark://venue/{venueId}
        if urlString.contains("venue/") {
            let parts = urlString.components(separatedBy: "venue/")
            if parts.count > 1 {
                return parts[1].components(separatedBy: "/").first
            }
        }

        return nil
    }

    private func completeWithSuccess(_ venueId: String) {
        lastScannedVenueId = venueId
        lastError = nil
        scanStatus = .success(venueId: venueId)
        isScanning = false

        scanContinuation?.resume(returning: venueId)
        scanContinuation = nil
    }

    private func completeWithError(_ error: NFCError) {
        lastError = error
        scanStatus = .error(error)
        isScanning = false

        scanContinuation?.resume(throwing: error)
        scanContinuation = nil
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension RealNFCReaderService: NFCNDEFReaderSessionDelegate {

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            let nfcError = error as NSError

            // Check if user cancelled
            if nfcError.code == NFCReaderError.readerSessionInvalidationErrorUserCanceled.rawValue {
                completeWithError(.userCancelled)
                return
            }

            // Check if session timed out
            if nfcError.code == NFCReaderError.readerSessionInvalidationErrorSessionTimeout.rawValue {
                completeWithError(.sessionInvalidated)
                return
            }

            // Only report error if we didn't already complete successfully
            if scanContinuation != nil {
                completeWithError(.unknown(error.localizedDescription))
            }
        }
    }

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        Task { @MainActor in
            // Find venue ID in messages
            for message in messages {
                for record in message.records {
                    if let venueId = parseVenueId(from: record) {
                        // Update session alert
                        session.alertMessage = "Check-in erfolgreich! ✓"

                        completeWithSuccess(venueId)
                        return
                    }
                }
            }

            // No venue ID found
            session.alertMessage = "Ungültiger Tag"
            completeWithError(.noVenueIdFound)
        }
    }

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        // Handle tag detection if needed for more advanced scenarios
        guard let tag = tags.first else { return }

        session.connect(to: tag) { error in
            if let error = error {
                Task { @MainActor in
                    self.completeWithError(.tagReadFailed)
                }
                return
            }

            tag.readNDEF { message, error in
                if let error = error {
                    Task { @MainActor in
                        self.completeWithError(.unknown(error.localizedDescription))
                    }
                    return
                }

                guard let message = message else {
                    Task { @MainActor in
                        self.completeWithError(.invalidPayload)
                    }
                    return
                }

                Task { @MainActor in
                    // Process the message
                    for record in message.records {
                        if let venueId = self.parseVenueId(from: record) {
                            session.alertMessage = "Check-in erfolgreich! ✓"
                            self.completeWithSuccess(venueId)
                            return
                        }
                    }

                    self.completeWithError(.noVenueIdFound)
                }
            }
        }
    }
}

// MARK: - Preview Helper

extension RealNFCReaderService {
    /// Create a mock service for SwiftUI previews
    static var preview: RealNFCReaderService {
        let service = RealNFCReaderService()
        return service
    }
}
