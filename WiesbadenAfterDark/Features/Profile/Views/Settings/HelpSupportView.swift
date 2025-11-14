import SwiftUI

struct HelpSupportView: View {
    @State private var showEmailError = false

    var body: some View {
        List {
            // Contact Us Section
            Section {
                Button {
                    sendEmail()
                } label: {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        Text("Email Support")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                }

                Button {
                    openWhatsApp()
                } label: {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "message.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)

                        Text("WhatsApp Support")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                }

                Link(destination: URL(string: "tel:+4961217889900")!) {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)

                        Text("Call Support")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Text("+49 6121 7889900")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                }
            } header: {
                Text("Contact Us")
            } footer: {
                Text("Our support team is available Monday-Friday, 9:00-18:00 CET")
                    .font(Typography.captionMedium)
            }

            // Resources Section
            Section {
                NavigationLink(destination: FAQView()) {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)

                        Text("Frequently Asked Questions")
                            .font(Typography.bodyMedium)
                    }
                }

                NavigationLink(destination: PointsGuideView()) {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "star.circle.fill")
                            .foregroundColor(.yellow)
                            .frame(width: 24)

                        Text("How to Earn Points")
                            .font(Typography.bodyMedium)
                    }
                }

                NavigationLink(destination: VenueGuidelinesView()) {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        Text("Venue Guidelines")
                            .font(Typography.bodyMedium)
                    }
                }
            } header: {
                Text("Resources")
            }

            // About Section
            Section {
                HStack {
                    Text("App Version")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }

                Link(destination: URL(string: "https://wiesbadenafterdar.com")!) {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        Text("Visit Website")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.large)
        .alert("Email Unavailable", isPresented: $showEmailError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Unable to open email client. Please email us directly at support@wiesbadenafterdar.com")
        }
    }

    // MARK: - Contact Methods
    private func sendEmail() {
        let email = "support@wiesbadenafterdar.com"
        let subject = "Support Request - Wiesbaden After Dark"
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                showEmailError = true
            }
        }
    }

    private func openWhatsApp() {
        let phone = "4961217889900"
        if let url = URL(string: "https://wa.me/\(phone)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - FAQ View
struct FAQView: View {
    private let faqs: [FAQItem] = [
        FAQItem(
            question: "How do I earn points?",
            answer: "You can earn points by checking in at participating venues, referring friends to the app, and taking advantage of special offers with bonus multipliers. Each venue has its own point system."
        ),
        FAQItem(
            question: "When do points expire?",
            answer: "Points expire after 180 days of inactivity at a specific venue. You'll receive notifications 30 days before your points expire, giving you time to use them or earn more to reset the expiration timer."
        ),
        FAQItem(
            question: "Can I use points at any venue?",
            answer: "No, points are venue-specific. Points earned at one venue can only be spent at that same venue. This allows each venue to maintain its own rewards program and offerings."
        ),
        FAQItem(
            question: "How does the referral system work?",
            answer: "Share your unique referral code with friends. When they sign up and spend at any venue, you earn 25% of their points across 5 levels of your referral chain. The more friends you refer, the more you earn!"
        ),
        FAQItem(
            question: "What are tiers and how do I upgrade?",
            answer: "Tiers are loyalty levels at each venue. You upgrade by earning more points through check-ins and purchases. Higher tiers unlock better rewards, exclusive perks, and bonus multipliers."
        ),
        FAQItem(
            question: "How do I redeem my points?",
            answer: "Show your QR code at the venue when making a purchase. Staff will scan it and you can choose to redeem points for rewards from that venue's catalog."
        ),
        FAQItem(
            question: "Is my data secure?",
            answer: "Yes! We use industry-standard encryption and security practices. Your payment information is never stored on our servers, and you can enable biometric authentication for extra security."
        ),
        FAQItem(
            question: "Can I delete my account?",
            answer: "Yes, you can delete your account anytime from Privacy & Security settings. This will permanently remove all your data and cannot be undone."
        )
    ]

    var body: some View {
        List(faqs) { faq in
            FAQRow(item: faq)
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

struct FAQRow: View {
    let item: FAQItem
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            Text(item.answer)
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .padding(.top, Theme.Spacing.sm)
                .padding(.bottom, Theme.Spacing.xs)
        } label: {
            Text(item.question)
                .font(Typography.bodyMedium)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Points Guide View
struct PointsGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("How to Earn Points")
                        .font(Typography.titleLarge)
                        .foregroundColor(.textPrimary)

                    Text("Maximize your rewards with these earning strategies")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.lg)

                // Check-Ins
                GuideSection(
                    icon: "checkmark.circle.fill",
                    iconColor: .blue,
                    title: "Check-Ins",
                    description: "Visit participating venues and check in using the app. Each check-in earns base points that contribute to your tier progression."
                )

                // Purchases
                GuideSection(
                    icon: "creditcard.fill",
                    iconColor: .green,
                    title: "Purchases",
                    description: "Earn points for every euro spent. Higher tiers unlock better point multipliers, letting you earn even more."
                )

                // Referrals
                GuideSection(
                    icon: "person.3.fill",
                    iconColor: .purple,
                    title: "Referral Program",
                    description: "Share your referral code and earn 25% of your friends' points across 5 levels. Build your network to maximize passive earnings."
                )

                // Special Offers
                GuideSection(
                    icon: "star.fill",
                    iconColor: .yellow,
                    title: "Special Offers",
                    description: "Watch for limited-time bonus events with multipliers up to 5x. Perfect for tier upgrades and point boosts."
                )

                // Tier Benefits
                GuideSection(
                    icon: "trophy.fill",
                    iconColor: .orange,
                    title: "Tier Benefits",
                    description: "Higher tiers = better rewards. Unlock exclusive perks, priority access, and permanent point multipliers as you level up."
                )
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Color.appBackground)
        .navigationTitle("Points Guide")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Venue Guidelines View
struct VenueGuidelinesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("Venue Guidelines")
                        .font(Typography.titleLarge)
                        .foregroundColor(.textPrimary)

                    Text("Make the most of your Wiesbaden After Dark experience")
                        .font(Typography.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.lg)

                // Check-In Process
                GuideSection(
                    icon: "qrcode.viewfinder",
                    iconColor: .blue,
                    title: "Check-In Process",
                    description: "Show your unique QR code to venue staff for instant check-ins. Each venue has its own QR scanner for secure verification."
                )

                // Point Redemption
                GuideSection(
                    icon: "gift.fill",
                    iconColor: .green,
                    title: "Redeeming Rewards",
                    description: "Browse each venue's reward catalog in the app. Show your QR code at checkout to redeem points for rewards, discounts, or special items."
                )

                // Venue Etiquette
                GuideSection(
                    icon: "hand.raised.fill",
                    iconColor: .purple,
                    title: "Venue Etiquette",
                    description: "Be respectful of staff and other patrons. Venues reserve the right to refuse service or revoke points for inappropriate behavior."
                )

                // Age Restrictions
                GuideSection(
                    icon: "18.circle.fill",
                    iconColor: .red,
                    title: "Age Restrictions",
                    description: "Many venues serve alcohol and require guests to be 18+. Always carry valid ID and respect each venue's age policies."
                )

                // Support
                GuideSection(
                    icon: "questionmark.circle.fill",
                    iconColor: .orange,
                    title: "Need Help?",
                    description: "Contact venue staff directly for venue-specific questions, or reach out to our support team for app-related assistance."
                )
            }
            .padding(.bottom, Theme.Spacing.xl)
        }
        .background(Color.appBackground)
        .navigationTitle("Guidelines")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Guide Section Component
private struct GuideSection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 40)

                Text(title)
                    .font(Typography.headlineMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }

            Text(description)
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Theme.Spacing.lg)
        .background(Color.cardBackground)
        .cornerRadius(Theme.CornerRadius.md)
        .padding(.horizontal, Theme.Spacing.lg)
    }
}

#Preview("Help & Support") {
    NavigationStack {
        HelpSupportView()
    }
}

#Preview("FAQ") {
    NavigationStack {
        FAQView()
    }
}

#Preview("Points Guide") {
    NavigationStack {
        PointsGuideView()
    }
}

#Preview("Venue Guidelines") {
    NavigationStack {
        VenueGuidelinesView()
    }
}
