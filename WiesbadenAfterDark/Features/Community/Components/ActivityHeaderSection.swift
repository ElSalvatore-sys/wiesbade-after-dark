//
//  ActivityHeaderSection.swift
//  WiesbadenAfterDark
//
//  Purpose: Shows current venue activity
//  "5 people at Das Wohnzimmer right now"
//

import SwiftUI

/// Header showing live venue activity
struct ActivityHeaderSection: View {
    // Mock data - replace with real data
    let activeVenues: [(name: String, count: Int)] = [
        ("Das Wohnzimmer", 12),
        ("Harput Restaurant", 8),
        ("Park Café", 5)
    ]

    /// Callback when a venue bubble is tapped
    var onVenueTap: ((String) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Live Activity")
                    .font(.headline)
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                // Pulsing indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.green.opacity(0.5), lineWidth: 2)
                            .scaleEffect(1.5)
                    )
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(activeVenues, id: \.name) { venue in
                        ActivityBubble(
                            venueName: venue.name,
                            peopleCount: venue.count,
                            onTap: {
                                onVenueTap?(venue.name)
                            }
                        )
                    }
                }
            }
        }
    }
}

/// Activity bubble for venue
struct ActivityBubble: View {
    let venueName: String
    let peopleCount: Int
    var onTap: (() -> Void)? = nil

    @State private var isPressed = false

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "figure.2.circle.fill")
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 2) {
                    Text(venueName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)

                    Text("\(peopleCount) here now")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.textTertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.green.opacity(0.1))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

#Preview {
    ActivityHeaderSection(onVenueTap: { venue in
        print("Tapped: \(venue)")
    })
    .padding()
    .background(Color.appBackground)
}
