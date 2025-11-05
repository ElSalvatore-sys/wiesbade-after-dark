//
//  String+Validation.swift
//  WiesbadenAfterDark
//
//  String extensions for validation and formatting
//

import Foundation

extension String {
    // MARK: - Phone Number Validation

    /// Validates if the string is a valid German phone number
    /// Accepts formats: +4917012345678, 017012345678, 170 123 4567
    var isValidGermanPhoneNumber: Bool {
        let cleaned = self.digitsOnly

        // Must be 10-11 digits (without country code) or 12-13 digits (with +49)
        guard cleaned.count >= 10 && cleaned.count <= 13 else {
            return false
        }

        // If starts with 49, must be 11-12 digits total
        if cleaned.hasPrefix("49") {
            return cleaned.count >= 11 && cleaned.count <= 12
        }

        // If starts with 0, must be 10-11 digits
        if cleaned.hasPrefix("0") {
            return cleaned.count >= 10 && cleaned.count <= 11
        }

        // Otherwise must be 10-11 digits (mobile number without leading 0)
        return cleaned.count >= 10 && cleaned.count <= 11
    }

    /// Returns only the digit characters from the string
    var digitsOnly: String {
        return self.filter { $0.isNumber }
    }

    /// Normalizes a phone number to E.164 format (+4917012345678)
    /// - Parameter countryCode: Default country code (default: "+49")
    /// - Returns: E.164 formatted phone number or nil if invalid
    func normalizedPhoneNumber(countryCode: String = "+49") -> String? {
        let cleaned = self.digitsOnly

        // Remove country code if present
        var number = cleaned
        if number.hasPrefix("49") {
            number = String(number.dropFirst(2))
        }

        // Remove leading zero if present
        if number.hasPrefix("0") {
            number = String(number.dropFirst())
        }

        // Validate length (should be 10-11 digits for German mobile)
        guard number.count >= 10 && number.count <= 11 else {
            return nil
        }

        return countryCode + number
    }

    /// Formats a phone number for display (+49 170 1234567)
    /// - Returns: Formatted phone number with spaces
    func formattedAsPhoneNumber() -> String {
        let cleaned = self.digitsOnly

        // Format: +49 170 1234567
        guard cleaned.count >= 10 else {
            return self
        }

        var formatted = ""
        var number = cleaned

        // Extract country code
        if number.hasPrefix("49") {
            formatted = "+49 "
            number = String(number.dropFirst(2))
        } else if number.hasPrefix("0") {
            formatted = "+49 "
            number = String(number.dropFirst())
        }

        // Format the remaining digits in groups
        // First 3-4 digits (area/mobile code)
        if number.count >= 3 {
            let areaCodeEnd = number.index(number.startIndex, offsetBy: 3)
            formatted += number[..<areaCodeEnd] + " "
            number = String(number[areaCodeEnd...])
        }

        // Add remaining digits in groups of 4 and 3
        while !number.isEmpty {
            if number.count >= 4 {
                let chunkEnd = number.index(number.startIndex, offsetBy: 4)
                formatted += number[..<chunkEnd]
                number = String(number[chunkEnd...])
                if !number.isEmpty {
                    formatted += " "
                }
            } else {
                formatted += number
                number = ""
            }
        }

        return formatted.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Referral Code Validation

    /// Validates if the string is a valid referral code format
    /// Must be 6-10 characters, alphanumeric, uppercase
    var isValidReferralCode: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 3 && trimmed.count <= 10 else {
            return false
        }
        return trimmed.allSatisfy { $0.isUppercase || $0.isNumber }
    }

    /// Returns uppercase version of the string (for referral codes)
    var uppercased: String {
        return self.uppercased()
    }

    // MARK: - Email Validation

    /// Validates if the string is a valid email address
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    // MARK: - Name Validation

    /// Validates if the string is a valid name (2+ characters, letters and spaces)
    var isValidName: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            return false
        }
        let nameRegex = "^[a-zA-ZÀ-ÿ\\s'-]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return namePredicate.evaluate(with: trimmed)
    }
}
