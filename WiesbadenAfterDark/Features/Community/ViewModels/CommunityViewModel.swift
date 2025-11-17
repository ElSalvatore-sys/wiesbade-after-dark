//
//  CommunityViewModel.swift
//  WiesbadenAfterDark
//
//  Purpose: Manages community feed data
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class CommunityViewModel {
    var posts: [Post] = []
    var isLoading = false
    var error: Error?

    func loadPosts() async {
        isLoading = true
        defer { isLoading = false }

        // Mock data for now
        try? await Task.sleep(for: .seconds(1))

        posts = [
            Post(
                userId: UUID(),
                type: .checkIn,
                content: "Amazing night at Das Wohnzimmer! 🍻 The DJ is killing it!",
                venueId: UUID(),
                venueName: "Das Wohnzimmer",
                userName: "Alex M."
            ),
            Post(
                userId: UUID(),
                type: .achievement,
                content: "Just reached Gold tier! 🎉 Thanks WiesbadenAfterDark!",
                userName: "Sarah K."
            ),
            Post(
                userId: UUID(),
                type: .photo,
                content: "Best cocktails in town! 🍹",
                venueId: UUID(),
                venueName: "Park Café",
                userName: "Mike R."
            ),
            Post(
                userId: UUID(),
                type: .checkIn,
                content: "Great vibes tonight! Love this place ❤️",
                venueId: UUID(),
                venueName: "Harput Restaurant",
                userName: "Lisa T."
            )
        ]
    }
}
