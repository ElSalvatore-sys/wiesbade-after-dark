import SwiftUI
import LocalAuthentication

struct PrivacySecurityView: View {
    @AppStorage("security.biometricAuth") private var biometricAuth = false
    @AppStorage("privacy.shareAnalytics") private var shareAnalytics = false
    @AppStorage("privacy.shareLocation") private var shareLocation = true

    @State private var showDeleteConfirmation = false
    @State private var showAuthenticationError = false
    @State private var authenticationErrorMessage = ""

    private var biometricManager: BiometricAuthManager {
        BiometricAuthManager.shared
    }

    var body: some View {
        List {
            // Security Section
            Section {
                // Biometric Authentication Toggle
                if biometricManager.isBiometricAvailable {
                    Toggle(isOn: Binding(
                        get: { biometricAuth },
                        set: { newValue in
                            if newValue {
                                Task {
                                    await enableBiometricAuth()
                                }
                            } else {
                                biometricAuth = false
                            }
                        }
                    )) {
                        HStack(spacing: Theme.Spacing.md) {
                            Image(systemName: biometricIconName)
                                .foregroundColor(.blue)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Use \(biometricDisplayName)")
                                    .font(Typography.bodyMedium)
                                    .foregroundColor(.textPrimary)

                                Text("Secure app with biometric authentication")
                                    .font(Typography.captionMedium)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }

                // Change PIN Button
                Button {
                    // TODO: Implement PIN change flow
                } label: {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "lock.rotation")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        Text("Change Security PIN")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
                    }
                }
            } header: {
                Text("Security")
            } footer: {
                if !biometricManager.isBiometricAvailable {
                    Text("Biometric authentication is not available on this device")
                        .font(Typography.captionMedium)
                }
            }

            // Privacy Section
            Section {
                Toggle(isOn: $shareAnalytics) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Share Usage Analytics")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)

                        Text("Help improve the app with anonymous data")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }
                }

                Toggle(isOn: $shareLocation) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Location Services")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)

                        Text("Show nearby venues and events")
                            .font(Typography.captionMedium)
                            .foregroundColor(.textSecondary)
                    }
                }

                NavigationLink(destination: DataManagementView()) {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "person.text.rectangle")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        Text("Manage Personal Data")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.textPrimary)
                    }
                }
            } header: {
                Text("Privacy")
            } footer: {
                Text("We respect your privacy and only collect data necessary to provide our services")
                    .font(Typography.captionMedium)
            }

            // Delete Account Section
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .frame(width: 24)

                        Text("Delete Account")
                            .font(Typography.bodyMedium)
                            .foregroundColor(.red)
                    }
                }
            } footer: {
                Text("Permanently delete your account and all associated data. This action cannot be undone.")
                    .font(Typography.captionMedium)
            }
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // TODO: Implement account deletion
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        .alert("Authentication Failed", isPresented: $showAuthenticationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authenticationErrorMessage)
        }
    }

    // MARK: - Biometric Authentication
    private func enableBiometricAuth() async {
        do {
            let result = try await biometricManager.authenticate(
                reason: "Enable biometric authentication for app security"
            )

            await MainActor.run {
                if result {
                    biometricAuth = true
                } else {
                    biometricAuth = false
                    authenticationErrorMessage = "Authentication failed. Please try again."
                    showAuthenticationError = true
                }
            }
        } catch {
            await MainActor.run {
                biometricAuth = false
                authenticationErrorMessage = error.localizedDescription
                showAuthenticationError = true
            }
        }
    }

    private var biometricIconName: String {
        switch biometricManager.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .opticID:
            return "opticid"
        default:
            return "lock.fill"
        }
    }

    private var biometricDisplayName: String {
        switch biometricManager.biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        default:
            return "Biometric Authentication"
        }
    }
}

// MARK: - Data Management View
struct DataManagementView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    PlaceholderView(title: "Download Data")
                } label: {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "arrow.down.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        Text("Download Your Data")
                            .font(Typography.bodyMedium)
                    }
                }

                NavigationLink {
                    PlaceholderView(title: "Data Usage")
                } label: {
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "chart.bar")
                            .foregroundColor(.blue)
                            .frame(width: 24)

                        Text("View Data Usage")
                            .font(Typography.bodyMedium)
                    }
                }
            } header: {
                Text("Your Data")
            } footer: {
                Text("Under GDPR, you have the right to access, correct, and delete your personal data")
                    .font(Typography.captionMedium)
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Placeholder View
private struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "wrench.and.screwdriver")
                .font(.system(size: 60))
                .foregroundColor(.textSecondary)

            Text("Feature Coming Soon")
                .font(Typography.titleMedium)
                .foregroundColor(.textPrimary)

            Text("\(title) will be available in a future update")
                .font(Typography.bodyMedium)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview("Privacy & Security") {
    NavigationStack {
        PrivacySecurityView()
    }
}

#Preview("Data Management") {
    NavigationStack {
        DataManagementView()
    }
}
