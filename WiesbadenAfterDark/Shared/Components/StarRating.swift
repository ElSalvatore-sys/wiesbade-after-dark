//
//  StarRating.swift
//  WiesbadenAfterDark
//
//  Star rating display component
//

import SwiftUI

/// Displays star rating (1.0-5.0)
struct StarRating: View {
    let rating: Decimal
    var size: CGFloat = 14
    var color: Color = .gold
    var showRatingText: Bool = true

    private var ratingValue: Double {
        NSDecimalNumber(decimal: rating).doubleValue
    }

    var body: some View {
        HStack(spacing: 2) {
            // Stars
            ForEach(0..<5, id: \.self) { index in
                starImage(for: index)
                    .foregroundColor(color)
                    .font(.system(size: size))
            }

            // Rating text
            if showRatingText {
                Text(String(format: "%.1f", ratingValue))
                    .font(Typography.labelSmall)
                    .foregroundColor(.textSecondary)
                    .padding(.leading, 4)
            }
        }
    }

    /// Determines which star image to show (filled, half, or empty)
    private func starImage(for index: Int) -> Image {
        let starValue = ratingValue - Double(index)

        if starValue >= 1.0 {
            return Image(systemName: "star.fill")
        } else if starValue >= 0.5 {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }
}

// MARK: - Preview
#Preview("Star Ratings") {
    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
        StarRating(rating: 5.0)
        StarRating(rating: 4.7)
        StarRating(rating: 4.2)
        StarRating(rating: 3.5)
        StarRating(rating: 2.8)
        StarRating(rating: 1.0)

        Divider()

        StarRating(rating: 4.7, size: 20, showRatingText: false)
    }
    .padding()
    .background(Color.appBackground)
}
