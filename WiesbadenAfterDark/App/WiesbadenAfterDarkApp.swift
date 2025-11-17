//
//  WiesbadenAfterDarkApp.swift
//  WiesbadenAfterDark
//
//  Main app entry point
//

import SwiftUI
import SwiftData

@main
struct WiesbadenAfterDarkApp: App {
    // MARK: - SwiftData Container

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Venue.self,
            Event.self,
            Booking.self,
            CommunityPost.self,
            Reward.self,
            VenueMembership.self,
            CheckIn.self,
            WalletPass.self,
            PointTransaction.self,
            Payment.self,
            PointsPurchase.self,
            Refund.self,
            PointExpiration.self,
            // NEW MODELS from 11 agents
            Product.self,              // Agent 1 & 3: Product model with inventory gamification
            // OrderItem is a DTO struct, not a @Model - removed from schema
            ReferralChain.self,        // Agent 4: 5-level referral tracking
            BadgeConfig.self,          // Agent 9: Custom achievement badges
            VenueTierConfig.self,      // Agent 9: Venue-specific tier configuration
            // COMMUNITY FEATURE: Social feed models
            Post.self,                 // Social posts (check-ins, status, photos)
            Comment.self               // Comments on posts
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - State

    @State private var authViewModel: AuthenticationViewModel?
    @State private var venueViewModel: VenueViewModel?

    // MARK: - Initialization

    init() {
        // Register background task for points expiration
        Task { @MainActor in
            PointsExpirationService.shared.registerBackgroundTask()
        }
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            if let authViewModel = authViewModel, let venueViewModel = venueViewModel {
                RootView()
                    .environment(authViewModel)
                    .environment(venueViewModel)
                    .modelContainer(sharedModelContainer)
            } else {
                // Loading state while initializing
                ProgressView()
                    .onAppear {
                        // Initialize view models with model context
                        let context = sharedModelContainer.mainContext
                        authViewModel = AuthenticationViewModel(modelContext: context)
                        venueViewModel = VenueViewModel(modelContext: context)

                        // Configure points expiration service
                        Task { @MainActor in
                            PointsExpirationService.shared.configure(with: context)
                            PointsExpirationService.shared.scheduleBackgroundTask()
                        }

                        // Initialize RealWalletPassService with model context
                        RealWalletPassService.shared.setModelContext(context)
                    }
            }
        }
    }
}

// MARK: - Root View

/// Root view that manages navigation based on authentication state
struct RootView: View {
    @Environment(AuthenticationViewModel.self) private var viewModel

    var body: some View {
        Group {
            switch viewModel.authState {
            case .initializing:
                // Show splash screen while checking session
                SplashView()

            case .unauthenticated, .error:
                // Show onboarding flow
                OnboardingFlow()

            case .authenticated:
                // Show main app (tab bar)
                MainTabView()

            case .authenticating:
                // Show loading state during authentication
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.appBackground.ignoresSafeArea())
            }
        }
        .animation(.easeInOut, value: viewModel.authState)
    }
}

// MARK: - Onboarding Flow

/// Navigation stack for the onboarding flow
struct OnboardingFlow: View {
    @Environment(AuthenticationViewModel.self) private var viewModel
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            WelcomeView {
                navigationPath.append(OnboardingRoute.phoneInput)
            }
            .navigationDestination(for: OnboardingRoute.self) { route in
                switch route {
                case .welcome:
                    WelcomeView {
                        navigationPath.append(OnboardingRoute.phoneInput)
                    }

                case .phoneInput:
                    PhoneInputView {
                        navigationPath.append(OnboardingRoute.verification(phoneNumber: viewModel.currentPhoneNumber))
                    }

                case .verification(let phoneNumber):
                    VerificationCodeView(phoneNumber: phoneNumber) {
                        // Check auth state - only navigate to referral if NOT authenticated
                        // If user is authenticated (existing user), root navigation will handle it
                        if case .authenticated = viewModel.authState {
                            print("🏠 [Navigation] User authenticated - let root navigation handle (go to home)")
                            // Don't navigate - authenticated users go straight to MainTabView
                        } else {
                            print("📝 [Navigation] New user - proceeding to referral code input")
                            navigationPath.append(OnboardingRoute.referralCode)
                        }
                    }

                case .referralCode:
                    ReferralCodeInputView {
                        // Navigation handled by auth state change
                    }
                }
            }
        }
    }
}

// MARK: - Main Tab View

/// Main tab bar navigation with 5 tabs
struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Discover tab
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "map.fill")
                }
                .tag(1)

            // Events tab
            EventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
                .tag(2)

            // Community tab
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.2.fill")
                }
                .tag(3)

            // Profile tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .tint(Color.gold)  // Use gold color for tab bar tint instead of .primary
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            // CRITICAL FIX: Handle memory warnings by clearing caches
            print("⚠️ [Memory] Received memory warning - clearing caches")
            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.diskCapacity = 0
            URLCache.shared.memoryCapacity = 0
        }
    }
}

// MARK: - Placeholder Views

/// Placeholder for global events view (to be implemented)
private struct EventsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: Theme.Spacing.lg) {
                    Image(systemName: "calendar")
                        .font(.system(size: 60))
                        .foregroundColor(.textTertiary)

                    Text("Events Coming Soon")
                        .font(Typography.titleMedium)
                        .foregroundColor(.textPrimary)

                    Text("Discover events at your favorite venues from the Discover tab")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
            }
            .navigationTitle("Events")
        }
    }
}

/// Placeholder for global community view (to be implemented)
private struct CommunityPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: Theme.Spacing.lg) {
                    Image(systemName: "person.2")
                        .font(.system(size: 60))
                        .foregroundColor(.textTertiary)

                    Text("Community Coming Soon")
                        .font(Typography.titleMedium)
                        .foregroundColor(.textPrimary)

                    Text("Connect with venue communities from the Discover tab")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
            }
            .navigationTitle("Community")
        }
    }
}
