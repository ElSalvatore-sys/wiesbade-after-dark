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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Live Activity")
                .font(.headline)
                .foregroundStyle(Color.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(activeVenues, id: \.name) { venue in
                        ActivityBubble(
                            venueName: venue.name,
                            peopleCount: venue.count
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

    var body: some View {
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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.1))
        .cornerRadius(20)
    }
}

#Preview {
    ActivityHeaderSection()
        .padding()
        .background(Color.appBackground)
}
