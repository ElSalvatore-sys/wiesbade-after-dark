//
//  WiesbadenAfterDarkApp.swift
//  WiesbadenAfterDark
//
//  Main app entry point
//

import SwiftUI
import SwiftData
import UIKit

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

        // Configure UITabBar appearance for consistent look across iOS versions
        configureTabBarAppearance()
    }

    /// Configures the global tab bar appearance for iOS 17+ compatibility
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()

        // Use transparent background with glossy blur effect for iOS 17/18
        appearance.configureWithTransparentBackground()

        // Set semi-transparent background color
        appearance.backgroundColor = UIColor(red: 0.035, green: 0.035, blue: 0.043, alpha: 0.85)

        // Add glossy blur effect - systemChromeMaterialDark gives the best iOS 17+ look
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterialDark)

        // Add subtle shadow for depth
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.3)

        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()

        // Normal state - muted gray
        itemAppearance.normal.iconColor = UIColor(white: 0.5, alpha: 1.0)
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(white: 0.5, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]

        // Selected state - gold accent
        let goldColor = UIColor(red: 0.831, green: 0.686, blue: 0.216, alpha: 1.0)
        itemAppearance.selected.iconColor = goldColor
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: goldColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        // Apply to all tab bars - both standard and scroll edge must match
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        // Ensure bar is not translucent (we handle blur ourselves)
        UITabBar.appearance().isTranslucent = true
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
                        // Check auth state - only navigate to name input if NOT authenticated
                        // If user is authenticated (existing user), root navigation will handle it
                        if case .authenticated = viewModel.authState {
                            print("🏠 [Navigation] User authenticated - let root navigation handle (go to home)")
                            // Don't navigate - authenticated users go straight to MainTabView
                        } else {
                            print("📝 [Navigation] New user - proceeding to name input")
                            navigationPath.append(OnboardingRoute.nameInput)
                        }
                    }

                case .nameInput:
                    NameInputView {
                        navigationPath.append(OnboardingRoute.referralCode)
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

/// Main tab bar navigation with 5 tabs and custom glossy tab bar
struct MainTabView: View {
    @State private var selectedTab = 0

    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("map.fill", "Discover"),
        ("calendar", "Events"),
        ("person.2.fill", "Community"),
        ("person.crop.circle.fill", "Profile")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab
            Group {
                switch selectedTab {
                case 0: HomeView()
                case 1: DiscoverView()
                case 2: EventsView()
                case 3: CommunityView()
                case 4: ProfileView()
                default: HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom glossy tab bar
            GlossyTabBar(selectedTab: $selectedTab, tabs: tabs)
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
            // CRITICAL FIX: Handle memory warnings by clearing caches
            print("⚠️ [Memory] Received memory warning - clearing caches")
            URLCache.shared.removeAllCachedResponses()
            URLCache.shared.diskCapacity = 0
            URLCache.shared.memoryCapacity = 0
        }
    }
}

// MARK: - Glossy Tab Bar

/// Custom tab bar with glassmorphism effect
private struct GlossyTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 22))
                            .symbolRenderingMode(.hierarchical)

                        Text(tab.label)
                            .font(.system(size: 10, weight: selectedTab == index ? .semibold : .medium))
                    }
                    .foregroundColor(selectedTab == index ? Color.gold : Color(white: 0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 28) // Account for home indicator
        .background(
            ZStack {
                // Blur effect layer
                VisualEffectBlur(blurStyle: .systemChromeMaterialDark)

                // Gradient overlay for extra depth
                LinearGradient(
                    colors: [
                        Color(white: 0.15, opacity: 0.3),
                        Color(white: 0.05, opacity: 0.5)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Top border highlight
                VStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 0.5)
                    Spacer()
                }
            }
        )
    }
}

// MARK: - Visual Effect Blur (UIKit Bridge)

/// UIViewRepresentable for UIVisualEffectView blur
private struct VisualEffectBlur: UIViewRepresentable {
    let blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
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
