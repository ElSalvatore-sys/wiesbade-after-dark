//
//  APIConfig.swift
//  WiesbadenAfterDark
//
//  API Configuration for production backend
//

import Foundation

enum APIConfig {
    // MARK: - Base URL

    /// Production backend URL (Railway deployment)
    static let baseURL = "https://wiesbade-after-dark-production.up.railway.app"

    // MARK: - Endpoints

    enum Endpoints {
        // Authentication
        static let sendVerificationCode = "/api/v1/auth/send-code"
        static let verifyCode = "/api/v1/auth/verify-code"
        static let register = "/api/v1/auth/register"
        static let login = "/api/v1/auth/login"
        static let refreshToken = "/api/v1/auth/refresh"

        // Users
        static let userProfile = "/api/v1/users/me"
        static let updateProfile = "/api/v1/users/me"
        static let validateReferralCode = "/api/v1/users/validate-referral"

        // Venues
        static let venues = "/api/v1/venues"
        static func venueDetail(id: String) -> String { "/api/v1/venues/\(id)" }
        static func venueEvents(id: String) -> String { "/api/v1/venues/\(id)/events" }
        static func venueRewards(id: String) -> String { "/api/v1/venues/\(id)/rewards" }
        static func venueCommunity(id: String) -> String { "/api/v1/venues/\(id)/community" }
        static func joinVenue(id: String) -> String { "/api/v1/venues/\(id)/join" }
        static func venueMembership(venueId: String, userId: String) -> String {
            "/api/v1/venues/\(venueId)/members/\(userId)"
        }

        // Events
        static func rsvpEvent(id: String) -> String { "/api/v1/events/\(id)/rsvp" }
        static let myEvents = "/api/v1/events/my-events"

        // Bookings
        static let createBooking = "/api/v1/bookings"
        static let myBookings = "/api/v1/bookings/my-bookings"
        static func bookingDetail(id: String) -> String { "/api/v1/bookings/\(id)" }
        static func cancelBooking(id: String) -> String { "/api/v1/bookings/\(id)/cancel" }

        // Check-ins
        static let checkIn = "/api/v1/check-ins"
        static func checkInHistory(userId: String) -> String { "/api/v1/check-ins/user/\(userId)" }
        static func currentStreak(userId: String) -> String { "/api/v1/check-ins/user/\(userId)/streak" }

        // Wallet Passes
        static let walletPasses = "/api/v1/wallet-passes"
        static func generatePass(bookingId: String) -> String { "/api/v1/wallet-passes/generate/\(bookingId)" }

        // Payments
        static let createPaymentIntent = "/api/v1/payments/create-intent"
        static let confirmPayment = "/api/v1/payments/confirm"
        static let paymentHistory = "/api/v1/payments/my-payments"
        static func refundPayment(id: String) -> String { "/api/v1/payments/\(id)/refund" }

        // Rewards
        static func redeemReward(id: String) -> String { "/api/v1/rewards/\(id)/redeem" }

        // Referrals
        static func userReferrals(userId: String) -> String { "/api/v1/users/\(userId)/referrals" }
        static let processReferralRewards = "/api/v1/referrals/process-rewards"
    }

    // MARK: - Headers

    static func headers(with token: String? = nil) -> [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }

        return headers
    }
}
