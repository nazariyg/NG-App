// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

// MARK: - Protocol

public protocol AppProtocol {
    func initialize(withLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    var isActive: P<Bool> { get }
    var version: String { get }
    var buildNumber: String { get }
    var fullVersion: String { get }
    func openSystemSettingsForApp()
    var events: O<App.Event> { get }

    // For AppDelegate.
    func _appWillEnterForeground()
    func _appDidBecomeActive()
    func _appWillResignActive()
    func _appDidEnterBackground()
    func _appWillTerminate()
}

// MARK: - Implementation

public final class App: AppProtocol, EventEmitter, SharedInstance {

    public enum Event {
        case willEnterForeground
        case didBecomeActive
        case willResignActive
        case didEnterBackground
        case willTerminate
    }

    public typealias InstanceProtocol = AppProtocol
    public static func defaultInstance() -> InstanceProtocol { return App() }
    public static let doesReinstantiate = false

    private var launchOptions: [UIApplication.LaunchOptionsKey: Any]?

    /// Skipping repeats.
    public private(set) lazy var isActive = P(_isActive.distinctUntilChanged())
    private let _isActive = V<Bool>(false)

    // MARK: - Lifecycle

    private init() {}

    // Called by AppDelegate.
    public func initialize(withLaunchOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        DispatchQueue.syncSafeOnMain {
            self.launchOptions = launchOptions
        }
    }

    // MARK: - App info

    public var version: String {
        return DispatchQueue.syncSafeOnMain {
            let infoDictionary = Bundle.main.infoDictionary
            let version = infoDictionary?["CFBundleShortVersionString"] as? String
            return version ?? ""
        }
    }

    public var buildNumber: String {
        return DispatchQueue.syncSafeOnMain {
            let infoDictionary = Bundle.main.infoDictionary
            let buildNumber = infoDictionary?["CFBundleVersion"] as? String
            return buildNumber ?? ""
        }
    }

    public var fullVersion: String {
        return DispatchQueue.syncSafeOnMain {
            let fullVersion = "\(version) (\(buildNumber))"
            return fullVersion
        }
    }

    // MARK: - System settings

    public func openSystemSettingsForApp() {
        DispatchQueue.main.async {
            let app = UIApplication.shared
            let settingsURL = URL(string: UIApplication.openSettingsURLString)!
            if app.canOpenURL(settingsURL) {
                app.open(settingsURL)
            }
        }
    }

    // MARK: - UIApplicationDelegate events to be called by the AppDelegate only

    public func _appWillEnterForeground() {
        DispatchQueue.syncSafeOnMain {
            eventEmitter.send(.willEnterForeground)
        }
    }

    public func _appDidBecomeActive() {
        DispatchQueue.syncSafeOnMain {
            _isActive.value = true
            eventEmitter.send(.didBecomeActive)
        }
    }

    public func _appWillResignActive() {
        DispatchQueue.syncSafeOnMain {
            eventEmitter.send(.willResignActive)
        }
    }

    public func _appDidEnterBackground() {
        DispatchQueue.syncSafeOnMain {
            _isActive.value = false
            eventEmitter.send(.didEnterBackground)
        }
    }

    public func _appWillTerminate() {
        DispatchQueue.syncSafeOnMain {
            eventEmitter.send(.willTerminate)
        }
    }

}
