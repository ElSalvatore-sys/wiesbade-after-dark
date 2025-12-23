//
//  NetworkMonitor.swift
//  WiesbadenAfterDark
//
//  Monitors network connectivity and notifies the app of changes
//

import Foundation
import Network
import Observation

/// Monitors network connectivity status
@Observable
final class NetworkMonitor {
    // MARK: - Singleton

    static let shared = NetworkMonitor()

    // MARK: - Properties

    /// Whether the device currently has network connectivity
    private(set) var isConnected: Bool = true

    /// Whether the connection is via cellular (expensive)
    private(set) var isExpensive: Bool = false

    /// Whether the connection is constrained (low data mode)
    private(set) var isConstrained: Bool = false

    /// The type of current connection
    private(set) var connectionType: ConnectionType = .unknown

    /// Whether we're currently monitoring
    private(set) var isMonitoring: Bool = false

    /// Last time connection status changed
    private(set) var lastStatusChange: Date = Date()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.wiesbadenafterdark.networkmonitor", qos: .utility)

    // MARK: - Connection Type

    enum ConnectionType: String {
        case wifi = "WiFi"
        case cellular = "Cellular"
        case wiredEthernet = "Ethernet"
        case unknown = "Unknown"
    }

    // MARK: - Initialization

    private init() {
        startMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Monitoring

    /// Start monitoring network connectivity
    func startMonitoring() {
        guard !isMonitoring else { return }

        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(path)
            }
        }

        monitor.start(queue: queue)
        isMonitoring = true

        #if DEBUG
        print("📡 [NetworkMonitor] Started monitoring network connectivity")
        #endif
    }

    /// Stop monitoring network connectivity
    func stopMonitoring() {
        guard isMonitoring else { return }

        monitor.cancel()
        isMonitoring = false

        #if DEBUG
        print("📡 [NetworkMonitor] Stopped monitoring network connectivity")
        #endif
    }

    // MARK: - Private Methods

    private func updateConnectionStatus(_ path: NWPath) {
        let wasConnected = isConnected

        isConnected = path.status == .satisfied
        isExpensive = path.isExpensive
        isConstrained = path.isConstrained

        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .wiredEthernet
        } else {
            connectionType = .unknown
        }

        // Track status change
        if wasConnected != isConnected {
            lastStatusChange = Date()

            #if DEBUG
            print("📡 [NetworkMonitor] Connection status changed: \(isConnected ? "Online" : "Offline") via \(connectionType.rawValue)")
            #endif

            // Post notification for components that need it
            NotificationCenter.default.post(
                name: .networkStatusChanged,
                object: nil,
                userInfo: ["isConnected": isConnected]
            )

            // Trigger sync when coming back online
            if isConnected && !wasConnected {
                NotificationCenter.default.post(name: .networkBecameAvailable, object: nil)
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
    static let networkBecameAvailable = Notification.Name("networkBecameAvailable")
}
