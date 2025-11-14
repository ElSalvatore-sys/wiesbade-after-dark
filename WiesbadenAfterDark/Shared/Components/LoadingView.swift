//
//  LoadingView.swift
//  WiesbadenAfterDark
//
//  Loading state component for async operations
//

import SwiftUI

/// Loading view with customizable message
struct LoadingView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).opacity(0.9))
    }
}

/// Inline loading indicator for smaller UI elements
struct InlineLoadingView: View {
    let message: String?

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        HStack(spacing: 12) {
            ProgressView()

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LoadingView(message: "Sending verification code...")

        InlineLoadingView(message: "Loading...")

        InlineLoadingView()
    }
}
