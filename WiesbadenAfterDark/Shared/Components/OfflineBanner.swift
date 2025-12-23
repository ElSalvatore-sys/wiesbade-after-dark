//
//  OfflineBanner.swift
//  WiesbadenAfterDark
//
//  Displays a banner when the app is offline and shows pending action count
//

import SwiftUI

/// Banner that appears when the device is offline
struct OfflineBanner: View {
    @State private var networkMonitor = NetworkMonitor.shared
    @State private var syncService = OfflineSyncService.shared

    @State private var showBanner = false
    @State private var wasOffline = false

    var body: some View {
        VStack(spacing: 0) {
            if showBanner {
                bannerContent
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showBanner)
        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            updateBannerState(isConnected: newValue)
        }
        .onAppear {
            // Check initial state
            if !networkMonitor.isConnected {
                showBanner = true
                wasOffline = true
            }
        }
    }

    private var bannerContent: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: networkMonitor.isConnected ? "wifi" : "wifi.slash")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            // Status text
            VStack(alignment: .leading, spacing: 2) {
                Text(statusText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)

                if syncService.pendingActionsCount > 0 && !networkMonitor.isConnected {
                    Text("\(syncService.pendingActionsCount) Aktionen warten auf Sync")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            Spacer()

            // Syncing indicator
            if syncService.isSyncing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            } else if networkMonitor.isConnected && wasOffline {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(bannerBackground)
    }

    private var bannerBackground: some View {
        Group {
            if networkMonitor.isConnected {
                // Connected - green/success
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.9),
                        Color.green.opacity(0.8)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            } else {
                // Offline - orange/warning
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.9),
                        Color.red.opacity(0.8)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            }
        }
    }

    private var statusText: String {
        if networkMonitor.isConnected {
            if syncService.isSyncing {
                return "Synchronisiere..."
            } else if wasOffline {
                return "Wieder online"
            } else {
                return "Verbunden"
            }
        } else {
            return "Offline-Modus"
        }
    }

    private func updateBannerState(isConnected: Bool) {
        if !isConnected {
            // Going offline
            showBanner = true
            wasOffline = true
            HapticManager.shared.warning()
        } else if wasOffline {
            // Coming back online
            showBanner = true
            HapticManager.shared.success()

            // Hide banner after delay when back online
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if networkMonitor.isConnected {
                    showBanner = false
                    wasOffline = false
                }
            }
        }
    }
}

// MARK: - Compact Offline Indicator

/// Compact indicator for navigation bars or toolbars
struct OfflineIndicator: View {
    @State private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        if !networkMonitor.isConnected {
            HStack(spacing: 4) {
                Image(systemName: "wifi.slash")
                    .font(.caption)
                Text("Offline")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.orange)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.15))
            .cornerRadius(8)
        }
    }
}

// MARK: - Pending Actions Badge

/// Badge showing number of pending offline actions
struct PendingActionsBadge: View {
    @State private var syncService = OfflineSyncService.shared

    var body: some View {
        if syncService.pendingActionsCount > 0 {
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption2)
                Text("\(syncService.pendingActionsCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.orange)
            .cornerRadius(10)
        }
    }
}

// MARK: - View Extension

extension View {
    /// Adds an offline banner at the top of the view
    func withOfflineBanner() -> some View {
        VStack(spacing: 0) {
            OfflineBanner()
            self
        }
    }
}

// MARK: - Preview

#Preview("Offline Banner") {
    VStack {
        OfflineBanner()
        Spacer()
        Text("Content")
        Spacer()
    }
    .background(Color.appBackground)
}

#Preview("Offline Indicator") {
    HStack {
        Text("Title")
        Spacer()
        OfflineIndicator()
    }
    .padding()
    .background(Color.appBackground)
}

#Preview("Pending Badge") {
    PendingActionsBadge()
        .padding()
        .background(Color.appBackground)
}
