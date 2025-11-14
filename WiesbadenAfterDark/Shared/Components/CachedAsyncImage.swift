//
//  CachedAsyncImage.swift
//  WiesbadenAfterDark
//
//  Reusable async image component with built-in caching and shimmer loading
//

import SwiftUI

/// AsyncImage wrapper with automatic caching and optimized loading
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let targetSize: CGSize
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    @State private var loadError: Error?

    init(
        url: URL?,
        targetSize: CGSize = CGSize(width: 400, height: 400),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.targetSize = targetSize
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = loadedImage {
                content(Image(uiImage: image))
            } else if loadError != nil {
                // Show error state
                placeholder()
            } else {
                // Show loading state
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
    }

    @MainActor
    private func loadImage() async {
        guard let url = url, !isLoading else { return }

        isLoading = true
        loadError = nil

        do {
            let image = try await ImageCache.shared.loadImage(from: url, targetSize: targetSize)
            loadedImage = image
        } catch {
            loadError = error
            print("Failed to load image from \(url): \(error.localizedDescription)")
        }

        isLoading = false
    }
}

// MARK: - Convenience Initializers

extension CachedAsyncImage where Placeholder == DefaultImagePlaceholder {
    /// Create CachedAsyncImage with default shimmer placeholder
    init(
        url: URL?,
        targetSize: CGSize = CGSize(width: 400, height: 400),
        @ViewBuilder content: @escaping (Image) -> Content
    ) {
        self.url = url
        self.targetSize = targetSize
        self.content = content
        self.placeholder = { DefaultImagePlaceholder() }
    }
}

/// Default placeholder with shimmer effect
struct DefaultImagePlaceholder: View {
    var body: some View {
        Rectangle()
            .fill(Color.cardBackground)
            .shimmer()
    }
}

// MARK: - Preview
#Preview("Cached Async Image") {
    VStack(spacing: Theme.Spacing.lg) {
        // With custom placeholder
        CachedAsyncImage(
            url: URL(string: "https://picsum.photos/400/300")
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
        } placeholder: {
            Rectangle()
                .fill(Color.inputBackground)
                .frame(height: 200)
                .shimmer()
        }
        .cornerRadius(Theme.CornerRadius.lg)

        // With default placeholder
        CachedAsyncImage(
            url: URL(string: "https://picsum.photos/400/400")
        ) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
        }
        .cornerRadius(Theme.CornerRadius.md)
    }
    .padding()
    .background(Color.appBackground)
}
