// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Alamofire

public typealias NetworkStatus = NetworkReachabilityManager.NetworkReachabilityStatus

// MARK: - Protocol

public protocol NetworkProtocol {
    var isOnline: O<Bool> { get }
    var isOnlineOrNil: P<Bool?> { get }
}

// MARK: - Implementation

public final class Network: NetworkProtocol, SharedInstance {

    public typealias InstanceProtocol = NetworkProtocol
    public static func defaultInstance() -> InstanceProtocol { return Network() }
    public static let doesReinstantiate = false

    /// Skipping repeats.
    public private(set) lazy var isOnline: O<Bool> = _isOnline.filterNil().distinctUntilChanged().share(replay: 1)
    public private(set) lazy var isOnlineOrNil = P(_isOnline.distinctUntilChanged())
    private let _isOnline = V<Bool?>(nil)

    private var reachabilityManager: NetworkReachabilityManager?

    // MARK: - Lifecycle

    private init() {
        if let reachabilityManager = NetworkReachabilityManager() {
            _isOnline.value = reachabilityManager.isReachable
        }

        startListeningOnReachability()
    }

    // MARK: - Network status

    private func startListeningOnReachability() {
        if let reachabilityManager = NetworkReachabilityManager() {
            self.reachabilityManager = reachabilityManager
            reachabilityManager.startListening { [weak self] status in
                self?.reachabilityStatusDidChange(toStatus: status)
            }
        } else {
            assertionFailure()
        }
    }

    private func reachabilityStatusDidChange(toStatus status: NetworkStatus) {
        switch status {
        case .reachable:
            _isOnline.value = true
        case .notReachable:
            _isOnline.value = false
        default: break
        }
    }

}

extension NetworkReachabilityManager.NetworkReachabilityStatus.ConnectionType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .ethernetOrWiFi: return "Wi-Fi"
        case .cellular: return "cellular"
        }
    }

}
