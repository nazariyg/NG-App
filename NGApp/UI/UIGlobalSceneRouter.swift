// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Cornerstones
import Core
import RxSwift
import UICore
import UIKit

final class UIGlobalSceneRouter: UIGlobalSceneRouterProtocol, SharedInstance {

    typealias InstanceProtocol = UIGlobalSceneRouterProtocol
    static func defaultInstance() -> InstanceProtocol { return UIGlobalSceneRouter() }
    static let doesReinstantiate = true

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    private init() {
        DispatchQueue.syncSafeOnMain {
            // Set the Core's shared instance with self.
            UICore.UIGlobalSceneRouter._defaultInstance = self
        }
    }

    // MARK: - Routing

    func go<Scene: UICore.UIScene>(_ toSceneType: Scene.Type, parameters: Scene.Parameters? = nil) {
        DispatchQueue.main.async {
            //
        }
    }

    // MARK: - Taking over after completed screens

    func takeover(afterSceneType sceneType: UISceneBase.Type, dismissalCompletion: VoidClosure?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            if sceneType == SplashScreenScene.self {
                // Splash screen -> Initial screen
                let initialSceneKind = UIInitializer.initialSceneKindAfterSplashScreen()
                Self.setInitialScene(ofKind: initialSceneKind)
            } else {
                self.goBackAfterTakingOver(dismissalCompletion: dismissalCompletion)
            }
        }
    }

    // MARK: - Private

    private static func setInitialScene(ofKind initialSceneKind: InitialSceneKind, completion: VoidClosure? = nil) {
        let transitionStyle: UISceneTransitionStyle =
            UIScener.shared.currentSceneType.value == SplashScreenScene.self ? .setAfterSplashScreen : .defaultSet

        switch initialSceneKind {

        case let .scene(sceneType):
            UIScener.shared.set(sceneType, transitionStyle: transitionStyle, completion: completion)

        case let .tabs(tabsControllerType, tabSceneTypes, initialTabIndex):
            UIScener.shared.set(
                tabsControllerType: tabsControllerType, tabSceneTypes: tabSceneTypes, initialTabIndex: initialTabIndex, transitionStyle: transitionStyle,
                completion: completion)

        }
    }

    private func goBackAfterTakingOver(dismissalCompletion: VoidClosure?) {
        UIScener.shared.back(completion: dismissalCompletion)
    }

}
