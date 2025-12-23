//
//  SoundManager.swift
//  WiesbadenAfterDark
//
//  Centralized sound effects manager for consistent audio feedback
//

import AVFoundation
import UIKit

/// Manages sound effects throughout the app
final class SoundManager {
    static let shared = SoundManager()

    // MARK: - Properties

    private var audioPlayers: [SoundType: AVAudioPlayer] = [:]
    private var isSoundEnabled: Bool = true

    // MARK: - Initialization

    private init() {
        setupAudioSession()
        preloadSounds()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            // Use ambient mode to mix with other audio and not interrupt music
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("⚠️ [SoundManager] Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Sound Types

    enum SoundType: String, CaseIterable {
        case checkInSuccess = "checkin_success"
        case pointsEarned = "points_earned"
        case levelUp = "level_up"
        case tierUpgrade = "tier_upgrade"
        case error = "error_buzz"
        case notification = "notification"
        case tap = "tap"
        case refresh = "refresh"
    }

    // MARK: - Preloading

    private func preloadSounds() {
        for soundType in SoundType.allCases {
            loadSound(soundType)
        }
    }

    private func loadSound(_ soundType: SoundType) {
        // Try to load custom sound file first
        if let url = Bundle.main.url(forResource: soundType.rawValue, withExtension: "wav") ??
           Bundle.main.url(forResource: soundType.rawValue, withExtension: "mp3") ??
           Bundle.main.url(forResource: soundType.rawValue, withExtension: "aiff") {
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                player.volume = volumeForSound(soundType)
                audioPlayers[soundType] = player
            } catch {
                print("⚠️ [SoundManager] Failed to load sound \(soundType.rawValue): \(error)")
            }
        }
        // If no custom sound, we'll use system sounds as fallback (see playSystemSound)
    }

    // MARK: - Volume Configuration

    private func volumeForSound(_ soundType: SoundType) -> Float {
        switch soundType {
        case .checkInSuccess, .tierUpgrade, .levelUp:
            return 0.8
        case .pointsEarned:
            return 0.6
        case .notification:
            return 0.7
        case .error:
            return 0.5
        case .tap, .refresh:
            return 0.3
        }
    }

    // MARK: - Sound Control

    /// Enable or disable all sounds
    func setEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "soundEffectsEnabled")
    }

    /// Check if sounds are enabled
    var isEnabled: Bool {
        return isSoundEnabled && UserDefaults.standard.bool(forKey: "soundEffectsEnabled")
    }

    // MARK: - Play Sounds

    /// Play a sound effect
    func play(_ soundType: SoundType) {
        guard isSoundEnabled else { return }

        if let player = audioPlayers[soundType] {
            // Use custom sound
            player.currentTime = 0
            player.play()
        } else {
            // Fall back to system sound
            playSystemSound(for: soundType)
        }
    }

    // MARK: - System Sound Fallbacks

    private func playSystemSound(for soundType: SoundType) {
        let soundID: SystemSoundID

        switch soundType {
        case .checkInSuccess:
            soundID = 1057 // Tweet sent sound - celebratory
        case .pointsEarned:
            soundID = 1054 // Pop sound
        case .levelUp, .tierUpgrade:
            soundID = 1025 // Fanfare-like sound
        case .error:
            soundID = 1053 // Error sound
        case .notification:
            soundID = 1007 // SMS received
        case .tap:
            soundID = 1104 // Keyboard tap
        case .refresh:
            soundID = 1105 // Light tap
        }

        AudioServicesPlaySystemSound(soundID)
    }

    // MARK: - Convenience Methods

    /// Check-in success sound with optional haptic pairing
    func playCheckInSuccess(withHaptic: Bool = true) {
        play(.checkInSuccess)
        if withHaptic {
            HapticManager.shared.checkInSuccess()
        }
    }

    /// Points earned chime
    func playPointsEarned(withHaptic: Bool = true) {
        play(.pointsEarned)
        if withHaptic {
            HapticManager.shared.pointsEarned()
        }
    }

    /// Level up celebration sound
    func playLevelUp(withHaptic: Bool = true) {
        play(.levelUp)
        if withHaptic {
            HapticManager.shared.success()
        }
    }

    /// Tier upgrade fanfare
    func playTierUpgrade(withHaptic: Bool = true) {
        play(.tierUpgrade)
        if withHaptic {
            HapticManager.shared.heavy()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                HapticManager.shared.success()
            }
        }
    }

    /// Error buzz
    func playError(withHaptic: Bool = true) {
        play(.error)
        if withHaptic {
            HapticManager.shared.error()
        }
    }

    /// Light tap sound for UI interactions
    func playTap() {
        play(.tap)
    }

    /// Refresh complete sound
    func playRefresh() {
        play(.refresh)
    }

    /// Notification received sound
    func playNotification() {
        play(.notification)
    }
}

// MARK: - Sound Resources Documentation
/*
 To add custom sounds:

 1. Create/obtain sound files in WAV, MP3, or AIFF format
 2. Keep sounds short (< 2 seconds) for UI feedback
 3. Add files to Resources/Sounds/ directory
 4. Name files to match SoundType raw values:
    - checkin_success.wav
    - points_earned.wav
    - level_up.wav
    - tier_upgrade.wav
    - error_buzz.wav
    - notification.wav
    - tap.wav
    - refresh.wav

 5. Add files to Xcode project (target: WiesbadenAfterDark)

 Recommended sound characteristics:
 - Check-in success: Coin/ding sound, 0.5-1s, bright and positive
 - Points earned: Short chime, 0.3-0.5s, ascending tone
 - Level up: Fanfare/celebration, 1-2s, triumphant
 - Tier upgrade: Longer celebration, 1.5-2s, prestigious
 - Error: Subtle buzz, 0.2-0.3s, not jarring
 - Tap: Very short click, 0.1s, subtle
 - Refresh: Whoosh or pop, 0.3s, satisfying
 */
