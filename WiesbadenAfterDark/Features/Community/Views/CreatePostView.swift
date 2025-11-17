//
//  CreatePostView.swift
//  WiesbadenAfterDark
//
//  Purpose: Create new social post
//

import SwiftUI

struct CreatePostView: View {
    @State private var content = ""
    @State private var selectedVenue: Venue?
    @State private var postType: PostType = .status
    @Environment(\.dismiss) private var dismiss

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

                if postType == .checkIn {
                    Section("Location") {
                        // Venue picker - simplified for now
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                            Text("Select venue...")
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
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
                    .disabled(content.isEmpty)
                }
            }
        }
    }

    private func postContent() {
        // TODO: Post to backend
        HapticManager.shared.success()
        dismiss()
    }
}

#Preview {
    CreatePostView()
}
