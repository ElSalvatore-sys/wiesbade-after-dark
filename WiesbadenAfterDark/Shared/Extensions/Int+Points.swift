//
//  Int+Points.swift
//  WiesbadenAfterDark
//
//  Points to Euro conversion extensions
//

import Foundation

/// Extension for Int to provide points-to-euro conversion utilities
extension Int {
    /// Convert points to euro value using the standard 10:1 ratio (10 points = €1)
    var euroValue: Double {
        Double(self) / 10.0
    }

    /// Convert points to formatted euro string (e.g., "45.00")
    var euroValueFormatted: String {
        String(format: "%.2f", euroValue)
    }

    /// Convert points to formatted euro string without decimals (e.g., "45")
    var euroValueFormattedWhole: String {
        String(format: "%.0f", euroValue)
    }

    /// Convert points to euro display string with currency symbol (e.g., "€45.00")
    var euroDisplay: String {
        "€\(euroValueFormatted)"
    }

    /// Convert points to euro display string without decimals (e.g., "€45")
    var euroDisplayWhole: String {
        "€\(euroValueFormattedWhole)"
    }
}
