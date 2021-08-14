// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Core
import UICore

struct UIInitializer {

    static func initAppUICreatingKeyWindow() -> UIWindow {
        return DispatchQueue.syncSafeOnMain {
            let initialSceneKind = splashScreenSceneKind()

            let screenSize = UIScreen.main.bounds.size
            let window = UIWindow(frame: CGRect(origin: .zero, size: screenSize))

            window.rootViewController = UIRootContainer.shared as? UIViewController

            let backgroundColor = UIConfig.appWindowBackgroundColor
            window.backgroundColor = backgroundColor
            UIRootContainer.shared.view.backgroundColor = backgroundColor

            window.makeKeyAndVisible()

            switch initialSceneKind {
            case let .scene(sceneType):
                UIScener.shared.initialize(initialSceneType: sceneType)
            case let .tabs(tabsControllerType, tabSceneTypes, initialTabIndex):
                UIScener.shared.initialize(tabsControllerType: tabsControllerType, tabSceneTypes: tabSceneTypes, initialTabIndex: initialTabIndex)
            }

            return window
        }
    }

    private static func splashScreenSceneKind() -> InitialSceneKind {
        return .scene(sceneType: SplashScreenScene.self)
    }

    static func initialSceneKindAfterSplashScreen() -> InitialSceneKind {
        return .scene(sceneType: HomeScene.self)
    }

}
