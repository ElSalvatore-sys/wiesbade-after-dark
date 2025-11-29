import SwiftUI

struct LegalView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxl) {
                // Terms of Service
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Terms of Service")
                            .font(Typography.titleLarge)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)

                        Text("Last updated: November 14, 2025")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }

                    LegalSection(
                        title: "Acceptance of Terms",
                        content: """
                        By accessing or using Wiesbaden After Dark ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.

                        [Legal team to review and complete]
                        """
                    )

                    LegalSection(
                        title: "Eligibility",
                        content: """
                        You must be at least 18 years old to use this App. By using the App, you represent and warrant that you meet this age requirement.

                        Many participating venues serve alcohol and enforce strict age verification policies. Valid government-issued identification may be required.
                        """
                    )

                    LegalSection(
                        title: "User Accounts",
                        content: """
                        You are responsible for:
                        • Maintaining the confidentiality of your account credentials
                        • All activities that occur under your account
                        • Notifying us immediately of unauthorized access

                        We reserve the right to terminate accounts that violate these terms or engage in fraudulent activity.

                        [Legal team to review and complete - cover registration, security, account termination]
                        """
                    )

                    LegalSection(
                        title: "Points System",
                        content: """
                        Points earned through the App are venue-specific digital rewards with no cash value. Points cannot be:
                        • Transferred between venues
                        • Transferred between users
                        • Exchanged for cash
                        • Sold or bartered

                        Points expire after 180 days of inactivity at a specific venue. Venues reserve the right to modify their point systems, rewards, and redemption policies at any time.

                        [Legal team to expand with redemption terms, expiration policy, dispute resolution]
                        """
                    )

                    LegalSection(
                        title: "Privacy and Data Collection",
                        content: """
                        Your use of the App is governed by our Privacy Policy. By using the App, you consent to our collection, use, and sharing of your information as described in the Privacy Policy.

                        [Cross-reference to Privacy Policy below]
                        """
                    )

                    LegalSection(
                        title: "User Conduct",
                        content: """
                        You agree not to:
                        • Violate any laws or regulations
                        • Harass, abuse, or harm other users or venue staff
                        • Attempt to manipulate the point system or referral program
                        • Use automated systems to interact with the App
                        • Share or sell your account credentials

                        [Legal team to review and complete - prohibited activities, content guidelines]
                        """
                    )

                    LegalSection(
                        title: "Intellectual Property",
                        content: """
                        All content, trademarks, and intellectual property in the App are owned by Wiesbaden After Dark or our licensors.

                        [Legal team to review and complete]
                        """
                    )

                    LegalSection(
                        title: "Limitation of Liability",
                        content: """
                        To the fullest extent permitted by law, Wiesbaden After Dark shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the App.

                        [Legal team to review and complete]
                        """
                    )

                    LegalSection(
                        title: "Changes to Terms",
                        content: """
                        We reserve the right to modify these terms at any time. Continued use of the App after changes constitutes acceptance of the modified terms.

                        [Legal team to complete notification process]
                        """
                    )

                    LegalSection(
                        title: "Governing Law",
                        content: """
                        These terms are governed by the laws of Germany.

                        [Legal team to specify jurisdiction, dispute resolution]
                        """
                    )

                    LegalSection(
                        title: "Contact",
                        content: """
                        For questions about these Terms of Service, contact:
                        Email: support@wiesbadenafterdar.com
                        Phone: +49 6121 7889900
                        """
                    )
                }

                Divider()
                    .padding(.vertical, Theme.Spacing.lg)

                // Privacy Policy
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Privacy Policy")
                            .font(Typography.titleLarge)
                            .fontWeight(.bold)
                            .foregroundColor(.textPrimary)

                        Text("Last updated: November 14, 2025")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }

                    LegalSection(
                        title: "Introduction",
                        content: """
                        Wiesbaden After Dark ("we," "our," or "us") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, and protect your information.
                        """
                    )

                    LegalSection(
                        title: "Information We Collect",
                        content: """
                        a) Account Information
                        • Name, email address, phone number
                        • Date of birth (for age verification)
                        • Profile photo (optional)

                        b) Location Data
                        • Approximate location for nearby venue discovery
                        • Precise location for venue check-ins
                        • Historical check-in locations
                        [Legal team to specify retention period and usage limitations]

                        c) Transaction Data
                        • Points earned and redeemed
                        • Venue visit history and check-in timestamps
                        • Referral activity and network connections
                        • Purchase history (amount, venue, date)

                        d) Device Information
                        • Device type, operating system version
                        • App version and settings
                        • IP address and browser information

                        [Legal team to complete and review all categories]
                        """
                    )

                    LegalSection(
                        title: "How We Use Your Information",
                        content: """
                        We use your information to:
                        • Provide and improve our services
                        • Process point transactions and rewards
                        • Send notifications about points, events, and offers
                        • Analyze app usage and performance
                        • Prevent fraud and ensure security
                        • Comply with legal obligations

                        [Legal team to review and complete with specific purposes and legal bases]
                        """
                    )

                    LegalSection(
                        title: "Data Sharing",
                        content: """
                        We do not sell your personal information. We may share data with:

                        • Venue Partners
                          Your check-ins and point activity are shared with venues you visit to enable rewards processing

                        • Service Providers
                          Third-party infrastructure, analytics, and communication services that support our operations

                        • Legal Requirements
                          When required by law or to protect our rights

                        [Legal team to expand with specific categories and safeguards]
                        """
                    )

                    LegalSection(
                        title: "Your Rights (GDPR Compliance)",
                        content: """
                        Under GDPR, you have the right to:

                        ✓ Access Your Data
                          Request a copy of all personal data we hold about you

                        ✓ Correct Inaccurate Data
                          Update or correct your information anytime

                        ✓ Request Deletion
                          Delete your account and associated data (subject to legal retention requirements)

                        ✓ Data Portability
                          Receive your data in a machine-readable format

                        ✓ Withdraw Consent
                          Opt out of non-essential data collection at any time

                        ✓ Object to Processing
                          Object to certain types of data processing

                        To exercise these rights, contact: support@wiesbadenafterdar.com
                        """
                    )

                    LegalSection(
                        title: "Data Security",
                        content: """
                        We implement industry-standard security measures to protect your data:
                        • End-to-end encryption for sensitive transactions
                        • Secure cloud infrastructure with regular backups
                        • Regular security audits and vulnerability testing
                        • Biometric authentication option for app access

                        [Legal team to review and complete]
                        """
                    )

                    LegalSection(
                        title: "Cookies and Tracking",
                        content: """
                        We use analytics and performance tracking to improve our services. You can opt out of non-essential tracking in Privacy & Security settings.

                        [Legal team to review and complete with specific tracking technologies]
                        """
                    )

                    LegalSection(
                        title: "Children's Privacy",
                        content: """
                        This app is not intended for users under 18 years of age. We do not knowingly collect data from minors.

                        [Legal team to complete]
                        """
                    )

                    LegalSection(
                        title: "International Data Transfers",
                        content: """
                        Your data may be processed in countries outside the European Economic Area (EEA). We ensure appropriate safeguards are in place for international transfers.

                        [Legal team to review and complete]
                        """
                    )

                    LegalSection(
                        title: "Data Retention",
                        content: """
                        We retain your data as long as your account is active or as needed to provide services. After account deletion, some data may be retained for legal compliance (e.g., transaction records for tax purposes).

                        [Legal team to specify retention periods for each data category]
                        """
                    )

                    LegalSection(
                        title: "Changes to Privacy Policy",
                        content: """
                        We may update this Privacy Policy from time to time. We will notify you of significant changes via email or in-app notification.

                        [Legal team to complete notification process]
                        """
                    )

                    LegalSection(
                        title: "Contact Information",
                        content: """
                        For privacy-related questions or to exercise your GDPR rights:

                        Email: support@wiesbadenafterdar.com
                        Phone: +49 6121 7889900

                        [Legal team to add: Data Protection Officer contact, company address]
                        """
                    )
                }
            }
            .padding(Theme.Spacing.lg)
        }
        .background(Color.appBackground)
        .navigationTitle("Legal")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Legal Section Component
private struct LegalSection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Typography.headlineMedium)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)

            Text(content)
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        LegalView()
    }
}
