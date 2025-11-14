//
//  ImageCache.swift
//  WiesbadenAfterDark
//
//  Image caching service for optimized loading and memory management
//

import SwiftUI
import UIKit

/// Thread-safe image caching service with memory management
@MainActor
final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default

    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Max 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB memory limit

        // Clear cache on memory warning
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.clearCache()
        }
    }

    /// Get cached image for URL
    func get(_ url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }

    /// Cache image for URL
    func set(_ image: UIImage, for url: URL) {
        let cost = image.size.width * image.size.height * 4 // Estimate bytes
        cache.setObject(image, forKey: url as NSURL, cost: Int(cost))
    }

    /// Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
    }

    /// Download and downsample image for optimal memory usage
    func loadImage(from url: URL, targetSize: CGSize = CGSize(width: 400, height: 400)) async throws -> UIImage {
        // Check cache first
        if let cached = get(url) {
            return cached
        }

        // Download image data
        let (data, _) = try await URLSession.shared.data(from: url)

        // Downsample to target size
        guard let image = downsample(imageData: data, to: targetSize) else {
            throw ImageCacheError.invalidImageData
        }

        // Cache the downsampled image
        set(image, for: url)

        return image
    }

    /// Downsample image data to target size for memory efficiency
    private func downsample(imageData: Data, to targetSize: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary

        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return nil
        }

        let maxDimensionInPixels = max(targetSize.width, targetSize.height) * UIScreen.main.scale

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }
}

// MARK: - Errors

enum ImageCacheError: LocalizedError {
    case invalidImageData
    case downloadFailed

    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "Unable to decode image data"
        case .downloadFailed:
            return "Failed to download image"
        }
    }
}
