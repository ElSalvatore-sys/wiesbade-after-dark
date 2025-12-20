//
//  APIConfig.swift
//  WiesbadenAfterDark
//
//  API Configuration for production backend
//

import Foundation

enum APIConfig {
    // MARK: - Base URL

    /// Production backend URL (Supabase Edge Functions)
    static let baseURL = "https://yyplbhrqtaeyzmcxpfli.supabase.co/functions/v1"

    /// Supabase anon key for API access
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5cGxiaHJxdGFleXptY3hwZmxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4NTMzMjcsImV4cCI6MjA4MDQyOTMyN30.qY10_JBCACxptGnrqS_ILhWsNsmMKgEitaXEtViBRQc"

    /// Legacy Railway URL (no longer active - trial expired)
    static let legacyRailwayURL = "https://wiesbade-after-dark-production.up.railway.app"

    // MARK: - Endpoints

    enum Endpoints {
        // Authentication (via Supabase Auth Edge Function)
        static let sendVerificationCode = "/auth/send-code"
        static let verifyCode = "/auth/verify-code"
        static let register = "/auth/register"
        static let login = "/auth/login"
        static let refreshToken = "/auth/refresh"

        // Users (via users Edge Function)
        static let userProfile = "/users/me"
        static let updateProfile = "/users/me"
        static let validateReferralCode = "/users/validate-referral"

        // Venues (via venues Edge Function)
        static let venues = "/venues"
        static func venueDetail(id: String) -> String { "/venues/\(id)" }
        static func venueEvents(id: String) -> String { "/events/venue/\(id)" }
        static func venueRewards(id: String) -> String { "/venues/\(id)/rewards" }
        static func venueCommunity(id: String) -> String { "/venues/\(id)/community" }
        static func joinVenue(id: String) -> String { "/venues/\(id)/join" }
        static func venueMembership(venueId: String, userId: String) -> String {
            "/venues/\(venueId)/members/\(userId)"
        }

        // Events (via events Edge Function)
        static func rsvpEvent(id: String) -> String { "/events/\(id)/rsvp" }
        static let myEvents = "/events/my-events"
        static let events = "/events"
        static let todayEvents = "/events/today"
        static let upcomingEvents = "/events/upcoming"
        static let featuredEvents = "/events/featured"

        // Bookings
        static let createBooking = "/bookings"
        static let myBookings = "/bookings/my-bookings"
        static func bookingDetail(id: String) -> String { "/bookings/\(id)" }
        static func cancelBooking(id: String) -> String { "/bookings/\(id)/cancel" }

        // Check-ins
        static let checkIn = "/check-ins"
        static func checkInHistory(userId: String) -> String { "/check-ins/user/\(userId)" }
        static func currentStreak(userId: String) -> String { "/check-ins/user/\(userId)/streak" }

        // Wallet Passes
        static let walletPasses = "/wallet-passes"
        static func generatePass(bookingId: String) -> String { "/wallet-passes/generate/\(bookingId)" }

        // Payments
        static let createPaymentIntent = "/payments/create-intent"
        static let confirmPayment = "/payments/confirm"
        static let paymentHistory = "/payments/my-payments"
        static func refundPayment(id: String) -> String { "/payments/\(id)/refund" }

        // Rewards
        static func redeemReward(id: String) -> String { "/rewards/\(id)/redeem" }

        // Referrals
        static func userReferrals(userId: String) -> String { "/users/\(userId)/referrals" }
        static let processReferralRewards = "/referrals/process-rewards"

        // Transactions
        static let createTransaction = "/transactions"
        static func userTransactions(userId: String) -> String { "/transactions/user/\(userId)" }

        // Products
        static func venueProducts(id: String) -> String { "/venues/\(id)/products" }
    }

    // MARK: - Headers

    static func headers(with token: String? = nil) -> [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "apikey": supabaseAnonKey  // Required for Supabase Edge Functions
        ]

        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }

        return headers
    }
}
