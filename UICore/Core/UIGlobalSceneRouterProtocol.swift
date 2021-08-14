// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift

public protocol UIGlobalSceneRouterProtocol {
    func go<Scene: UICore.UIScene>(_ toSceneType: Scene.Type, parameters: Scene.Parameters?)
    func takeover(afterSceneType sceneType: UISceneBase.Type, dismissalCompletion: VoidClosure?)
}

public extension UIGlobalSceneRouterProtocol {

    func go<Scene: UICore.UIScene>(_ toSceneType: Scene.Type, parameters: Scene.Parameters? = nil) {
        go(toSceneType, parameters: parameters)
    }

    func takeover(afterSceneType sceneType: UISceneBase.Type, dismissalCompletion: VoidClosure? = nil) {
        takeover(afterSceneType: sceneType, dismissalCompletion: dismissalCompletion)
    }

}
