// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import UICore

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize the app's core first.
        Core.initializeModule()

        // Initialize the app.
        App.shared.initialize(withLaunchOptions: launchOptions)

        // Initialize the UI at the system level.
        window = UIInitializer.initAppUICreatingKeyWindow()

        // Is run asynchronously because the key window is only accessible for UI initialization after `application(_:didFinishLaunchingWithOptions:)` returns.
        DispatchQueue.main.async {
            UICore.initializeModule()
            NGApp.initializeModule()
        }

        return true
    }

    // MARK: - UIApplicationDelegate events

    func applicationWillEnterForeground(_ application: UIApplication) {
        App.shared._appWillEnterForeground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        App.shared._appDidBecomeActive()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        App.shared._appWillResignActive()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        App.shared._appDidEnterBackground()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        App.shared._appWillTerminate()
    }

}
