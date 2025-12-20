//
//  BookingService.swift
//  WiesbadenAfterDark
//
//  Booking management service
//

import Foundation
import SwiftData

@MainActor
final class BookingService: BookingServiceProtocol {
    // MARK: - Properties

    private let paymentService: PaymentServiceProtocol
    private let modelContext: ModelContext?

    // MARK: - Initialization

    init(
        paymentService: PaymentServiceProtocol? = nil,
        modelContext: ModelContext? = nil
    ) {
        self.paymentService = paymentService ?? MockPaymentService.shared
        self.modelContext = modelContext
    }

    // MARK: - BookingServiceProtocol

    func createBooking(
        userId: UUID,
        venueId: UUID,
        tableType: TableType,
        partySize: Int,
        bookingDate: Date,
        timeSlot: String,
        specialRequests: String?,
        paymentMethod: PaymentMethodType,
        pointsToUse: Int?
    ) async throws -> BookingResult {
        print("📝 [Booking] Creating new booking...")
        print("📊 [Booking] Venue: \(venueId)")
        print("📊 [Booking] Table: \(tableType.displayName)")
        print("📊 [Booking] Party Size: \(partySize)")
        print("📊 [Booking] Date: \(bookingDate.formatted(date: .abbreviated, time: .omitted))")
        print("📊 [Booking] Payment Method: \(paymentMethod.rawValue)")

        // Validate party size
        guard partySize > 0, partySize <= tableType.maxCapacity else {
            print("❌ [Booking] Invalid party size")
            throw BookingError.invalidPartySize
        }

        // Check availability
        let isAvailable = try await checkAvailability(
            venueId: venueId,
            date: bookingDate,
            timeSlot: timeSlot,
            tableType: tableType
        )

        guard isAvailable else {
            print("❌ [Booking] Table not available")
            throw BookingError.tableNotAvailable
        }

        // Calculate pricing
        let tablePrice = tableType.basePrice
        let pointsCost = tableType.pointsCost

        var actualCashAmount = tablePrice
        var usedPoints = 0

        // Handle payment
        var paymentResult: PaymentResult
        let paymentDescription = "Table Booking - \(tableType.displayName)"

        switch paymentMethod {
        case .card:
            // Full card payment
            let intentId = try await paymentService.createPaymentIntent(
                amount: tablePrice,
                currency: "EUR"
            )
            paymentResult = try await paymentService.confirmPayment(
                paymentIntentId: intentId,
                paymentMethod: .card
            )

        case .applePay:
            // Apple Pay payment
            paymentResult = try await paymentService.processApplePayPayment(
                amount: tablePrice,
                description: paymentDescription
            )

        case .points:
            // Full points payment
            paymentResult = try await paymentService.processPointsPayment(
                userId: userId,
                points: pointsCost,
                description: paymentDescription
            )
            actualCashAmount = 0
            usedPoints = pointsCost

        case .combo:
            // Combo payment (points + cash)
            if let pointsToUse = pointsToUse {
                let pointsValue = PricingConfig.pointsToEuro(pointsToUse)
                actualCashAmount = max(0, tablePrice - pointsValue)

                paymentResult = try await paymentService.processComboPayment(
                    userId: userId,
                    points: pointsToUse,
                    cashAmount: actualCashAmount,
                    description: paymentDescription
                )
                usedPoints = pointsToUse
            } else {
                throw PaymentError.invalidAmount
            }

        default:
            throw PaymentError.paymentFailed("Unsupported payment method")
        }

        // Check payment success
        guard paymentResult.success else {
            print("❌ [Booking] Payment failed: \(paymentResult.errorMessage ?? "Unknown error")")
            return BookingResult(
                success: false,
                booking: nil,
                errorMessage: paymentResult.errorMessage
            )
        }

        // Create booking
        let confirmationCode = generateConfirmationCode()

        let booking = Booking(
            userId: userId,
            venueId: venueId,
            tableType: tableType,
            partySize: partySize,
            bookingDate: bookingDate,
            timeSlot: timeSlot,
            totalCost: tablePrice,
            paidWithPoints: paymentMethod == .points,
            pointsUsed: usedPoints > 0 ? usedPoints : nil,
            paymentStatus: .succeeded,
            paymentMethod: paymentMethod,
            amountPaid: actualCashAmount,
            status: .confirmed,
            specialRequests: specialRequests,
            confirmationCode: confirmationCode
        )

        // Save to SwiftData context
        if let context = modelContext {
            print("💾 [Booking] Saving to SwiftData...")
            print("   Booking ID: \(booking.id)")
            print("   User ID: \(userId)")
            print("   Venue ID: \(venueId)")
            print("   Table: \(tableType.displayName)")
            print("   Date: \(bookingDate.formatted(date: .abbreviated, time: .shortened))")
            print("   Status: \(booking.status.rawValue)")

            context.insert(booking)

            do {
                try context.save()
                print("✅ [Booking] Successfully saved to SwiftData!")
                print("📝 [Booking] Confirmation Code: \(confirmationCode)")
            } catch {
                print("❌ [Booking] CRITICAL: Failed to save booking to SwiftData!")
                print("❌ [Booking] Error: \(error.localizedDescription)")
                throw BookingError.saveFailed
            }
        } else {
            print("⚠️ [Booking] WARNING: No modelContext available - booking not persisted!")
        }

        print("✅ [Booking] Booking created successfully!")
        print("📝 [Booking] Confirmation: \(confirmationCode)")

        return BookingResult(
            success: true,
            booking: booking,
            errorMessage: nil
        )
    }

    func getBooking(id: UUID) async throws -> Booking? {
        guard let context = modelContext else {
            print("⚠️ [Booking] No modelContext available")
            return nil
        }

        let predicate = #Predicate<Booking> { booking in
            booking.id == id
        }
        let descriptor = FetchDescriptor<Booking>(predicate: predicate)

        do {
            let bookings = try context.fetch(descriptor)
            return bookings.first
        } catch {
            print("❌ [Booking] Failed to fetch booking: \(error)")
            throw BookingError.fetchFailed
        }
    }

    func getUserBookings(userId: UUID) async throws -> [Booking] {
        guard let context = modelContext else {
            print("⚠️ [Booking] No modelContext available")
            return []
        }

        let predicate = #Predicate<Booking> { booking in
            booking.userId == userId
        }
        var descriptor = FetchDescriptor<Booking>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.bookingDate, order: .reverse)]

        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ [Booking] Failed to fetch user bookings: \(error)")
            throw BookingError.fetchFailed
        }
    }

    func getVenueBookings(venueId: UUID, date: Date) async throws -> [Booking] {
        guard let context = modelContext else {
            print("⚠️ [Booking] No modelContext available")
            return []
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date

        let predicate = #Predicate<Booking> { booking in
            booking.venueId == venueId &&
            booking.bookingDate >= startOfDay &&
            booking.bookingDate < endOfDay
        }
        var descriptor = FetchDescriptor<Booking>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.bookingDate)]

        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ [Booking] Failed to fetch venue bookings: \(error)")
            throw BookingError.fetchFailed
        }
    }

    func cancelBooking(
        bookingId: UUID,
        reason: String,
        requestRefund: Bool
    ) async throws -> Bool {
        print("🚫 [Booking] Cancelling booking...")
        print("📊 [Booking] ID: \(bookingId)")
        print("📝 [Booking] Reason: \(reason)")
        print("💰 [Booking] Refund requested: \(requestRefund)")

        guard let context = modelContext else {
            print("⚠️ [Booking] No modelContext available")
            return false
        }

        // Fetch the booking
        guard let booking = try await getBooking(id: bookingId) else {
            print("❌ [Booking] Booking not found")
            throw BookingError.bookingNotFound
        }

        // Update booking status
        booking.status = .cancelled
        print("📝 [Booking] Cancellation reason: \(reason)")

        // Process refund if requested and payment was made
        let amountPaid = booking.amountPaid ?? 0
        if requestRefund && amountPaid > 0 {
            print("💰 [Booking] Processing refund of €\(amountPaid)...")
            // Refund logic would go here - for now just mark as refunded
            booking.paymentStatus = .refunded
        }

        // If points were used, restore them
        if let pointsUsed = booking.pointsUsed, pointsUsed > 0 {
            print("🎯 [Booking] Restoring \(pointsUsed) points to user")
            // Points restoration would be handled by PointsService
        }

        do {
            try context.save()
            print("✅ [Booking] Booking cancelled and saved")
            return true
        } catch {
            print("❌ [Booking] Failed to save cancellation: \(error)")
            throw BookingError.saveFailed
        }
    }

    func updateBooking(
        bookingId: UUID,
        partySize: Int?,
        specialRequests: String?
    ) async throws -> Booking {
        guard let context = modelContext else {
            throw BookingError.bookingNotFound
        }

        guard let booking = try await getBooking(id: bookingId) else {
            throw BookingError.bookingNotFound
        }

        // Update fields if provided
        if let newPartySize = partySize {
            guard newPartySize > 0, newPartySize <= booking.tableType.maxCapacity else {
                throw BookingError.invalidPartySize
            }
            booking.partySize = newPartySize
        }

        if let newRequests = specialRequests {
            booking.specialRequests = newRequests
        }

        do {
            try context.save()
            print("✅ [Booking] Booking updated successfully")
            return booking
        } catch {
            print("❌ [Booking] Failed to update booking: \(error)")
            throw BookingError.saveFailed
        }
    }

    func confirmBooking(bookingId: UUID) async throws -> Bool {
        // Venue confirms the booking
        print("✅ [Booking] Confirming booking: \(bookingId)")
        return true
    }

    func completeBooking(bookingId: UUID) async throws -> Bool {
        // Mark booking as completed after event
        print("✅ [Booking] Completing booking: \(bookingId)")
        return true
    }

    func checkAvailability(
        venueId: UUID,
        date: Date,
        timeSlot: String,
        tableType: TableType
    ) async throws -> Bool {
        // For mock, always return true
        // In production, check against existing bookings
        print("🔍 [Booking] Checking availability...")
        return true
    }

    // MARK: - Helper Methods

    private func generateConfirmationCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in letters.randomElement()! })
    }
}
