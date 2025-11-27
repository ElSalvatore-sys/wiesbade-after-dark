//
//  CreatePostView.swift
//  WiesbadenAfterDark
//
//  Purpose: Create new social post
//

import SwiftUI
import PhotosUI

struct CreatePostView: View {
    @State private var content = ""
    @State private var selectedVenueName: String? = nil
    @State private var postType: PostType = .status
    @State private var showVenuePicker = false
    @Environment(\.dismiss) private var dismiss

    // Photo picker state
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isLoadingImage = false

    // Mock venue list - in production, fetch from VenueService
    private let availableVenues = [
        "Das Wohnzimmer",
        "Harput Restaurant",
        "Park Café",
        "Hotel am Kochbrunnen",
        "Euro Palace",
        "Villa im Tal",
        "Kulturpalast"
    ]

    /// Check if post can be submitted
    private var canPost: Bool {
        // Must have content
        guard !content.isEmpty else { return false }

        // Check-in posts need venue
        if postType == .checkIn && selectedVenueName == nil {
            return false
        }

        // Photo posts need an image
        if postType == .photo && selectedImage == nil {
            return false
        }

        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("What's happening?") {
                    TextField("Share something...", text: $content, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Post Type") {
                    Picker("Type", selection: $postType) {
                        Text("Status").tag(PostType.status)
                        Text("Check-in").tag(PostType.checkIn)
                        Text("Photo").tag(PostType.photo)
                    }
                    .pickerStyle(.segmented)
                }

                // Photo section - show for photo posts OR any post that wants to add a photo
                Section {
                    photoSelectionView
                } header: {
                    Text("Photo")
                } footer: {
                    if postType == .photo && selectedImage == nil {
                        Text("A photo is required for photo posts")
                            .foregroundColor(.orange)
                    }
                }

                if postType == .checkIn {
                    Section("Location") {
                        Button {
                            showVenuePicker = true
                            HapticManager.shared.light()
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)

                                if let venue = selectedVenueName {
                                    Text(venue)
                                        .foregroundStyle(Color.textPrimary)
                                } else {
                                    Text("Select venue...")
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        postContent()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canPost)
                }
            }
            .sheet(isPresented: $showVenuePicker) {
                venuePickerSheet
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                loadSelectedPhoto(from: newItem)
            }
        }
    }

    // MARK: - Photo Selection View

    @ViewBuilder
    private var photoSelectionView: some View {
        if let image = selectedImage {
            // Show selected image with remove button
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    .clipped()
                    .cornerRadius(Theme.CornerRadius.md)

                // Remove button
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedImage = nil
                        selectedPhotoItem = nil
                    }
                    HapticManager.shared.light()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)
                }
                .padding(8)
            }

            // Option to change photo
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Change Photo")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        } else if isLoadingImage {
            // Loading state
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(.blue)
                    Text("Loading photo...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .frame(height: 100)
        } else {
            // Photo picker button
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 44, height: 44)

                        Image(systemName: "photo.badge.plus")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Add Photo")
                            .font(.body)
                            .foregroundStyle(Color.textPrimary)

                        Text("Choose from your library")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Photo Loading

    private func loadSelectedPhoto(from item: PhotosPickerItem?) {
        guard let item = item else { return }

        isLoadingImage = true

        Task {
            do {
                // Load the image data
                if let data = try await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedImage = uiImage
                            isLoadingImage = false
                        }
                        HapticManager.shared.medium()

                        // Auto-switch to photo type if not already
                        if postType == .status {
                            postType = .photo
                        }
                    }
                } else {
                    await MainActor.run {
                        isLoadingImage = false
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingImage = false
                    print("❌ [CreatePostView] Failed to load photo: \(error)")
                }
            }
        }
    }

    // MARK: - Venue Picker Sheet

    private var venuePickerSheet: some View {
        NavigationStack {
            List {
                ForEach(availableVenues, id: \.self) { venue in
                    Button {
                        selectedVenueName = venue
                        showVenuePicker = false
                        HapticManager.shared.medium()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(venue)
                                    .font(.body)
                                    .foregroundStyle(Color.textPrimary)

                                Text("Wiesbaden")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selectedVenueName == venue {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.appBackground)
            .navigationTitle("Select Venue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showVenuePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func postContent() {
        // TODO: Post to backend with image
        // In production: Upload image to storage, get URL, create post with imageURL

        if let image = selectedImage {
            print("📸 [CreatePostView] Posting with image: \(image.size)")
            // For now, just log the image size
            // Real implementation would upload to backend
        }

        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    CreatePostView()
}
