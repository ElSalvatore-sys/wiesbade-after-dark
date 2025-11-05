//
//  NFCReaderSheet.swift
//  WiesbadenAfterDark
//
//  NFC scanning modal sheet
//

import SwiftUI

/// NFC reader modal sheet
struct NFCReaderSheet: View {
    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Properties

    let venue: Venue
    let membership: VenueMembership
    let event: Event?
    let userId: UUID
    let viewModel: CheckInViewModel

    // MARK: - UI State

    @State private var nfcState: NFCScanState = .idle
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // NFC Animation
                    NFCScanAnimation(
                        state: nfcState,
                        message: errorMessage
                    )

                    Spacer()

                    // Action Button
                    actionButton
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                }
            }
            .navigationTitle("NFC Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if nfcState != .scanning && nfcState != .validating {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .task {
                // Start NFC scan automatically when sheet appears
                await startNFCScan()
            }
            .onChange(of: viewModel.checkInState) { _, newState in
                handleCheckInStateChange(newState)
            }
        }
    }

    // MARK: - Action Button

    @ViewBuilder
    private var actionButton: some View {
        switch nfcState {
        case .idle, .scanning, .validating:
            // No button during scanning
            EmptyView()

        case .success:
            Button(action: {
                dismiss()
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

        case .error:
            VStack(spacing: 12) {
                // Retry button
                Button(action: {
                    Task {
                        await startNFCScan()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Cancel button
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }

    // MARK: - NFC Scan Logic

    private func startNFCScan() async {
        // Reset state
        nfcState = .scanning
        errorMessage = nil

        // Perform NFC check-in
        await viewModel.performNFCCheckIn(
            userId: userId,
            venue: venue,
            membership: membership,
            event: event
        )
    }

    // MARK: - State Handling

    private func handleCheckInStateChange(_ state: CheckInState) {
        switch state {
        case .idle:
            nfcState = .idle

        case .scanning:
            nfcState = .scanning
            errorMessage = nil

        case .validating:
            nfcState = .validating
            errorMessage = nil

        case .processing:
            nfcState = .validating
            errorMessage = "Creating check-in record..."

        case .success:
            nfcState = .success
            errorMessage = nil
            // Auto-dismiss after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                dismiss()
            }

        case .error(let message):
            nfcState = .error
            errorMessage = message
        }
    }
}

// MARK: - Preview

#Preview("Scanning") {
    NFCReaderSheet(
        venue: Venue.mock(),
        membership: VenueMembership(
            userId: UUID(),
            venueId: Venue.mock().id,
            pointsBalance: 450,
            tier: .gold
        ),
        event: nil,
        userId: UUID(),
        viewModel: CheckInViewModel(
            checkInService: MockCheckInService.shared,
            walletPassService: MockWalletPassService.shared
        )
    )
}

#Preview("Error State") {
    struct PreviewWrapper: View {
        @State private var viewModel = CheckInViewModel(
            checkInService: MockCheckInService.shared,
            walletPassService: MockWalletPassService.shared
        )

        var body: some View {
            NFCReaderSheet(
                venue: Venue.mock(),
                membership: VenueMembership(
                    userId: UUID(),
                    venueId: Venue.mock().id,
                    pointsBalance: 450,
                    tier: .gold
                ),
                event: nil,
                userId: UUID(),
                viewModel: viewModel
            )
            .onAppear {
                viewModel.checkInState = .error(CheckInError.invalidNFCPayload.localizedDescription)
            }
        }
    }

    return PreviewWrapper()
}
