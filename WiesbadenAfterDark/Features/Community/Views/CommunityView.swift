//
//  CommunityView.swift
//  WiesbadenAfterDark
//
//  Purpose: Main community/social feed tab
//  Shows: User posts, check-ins, activity feed
//

import SwiftUI

/// Main community feed view
/// Instagram/Twitter-style social feed
struct CommunityView: View {
    @State private var viewModel = CommunityViewModel()
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Activity header
                        ActivityHeaderSection()
                            .padding(.horizontal)

                        // Posts feed
                        ForEach(viewModel.posts, id: \.id) { post in
                            PostCard(post: post)
                                .onTapGesture {
                                    // Navigate to post detail (optional)
                                }
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color.appBackground.ignoresSafeArea())

                // Loading overlay
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                            .scaleEffect(1.5)

                        Text("Loading community...")
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.appBackground)
                }
            }
            .navigationTitle("Community")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreatePost = true
                        HapticManager.shared.medium()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
            }
            .refreshable {
                await viewModel.loadPosts()
            }
            .task {
                await viewModel.loadPosts()
            }
        }
    }
}

#Preview {
    CommunityView()
}
