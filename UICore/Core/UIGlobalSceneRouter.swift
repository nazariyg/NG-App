// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift

public final class UIGlobalSceneRouter: SharedInstance {

    public typealias InstanceProtocol = UIGlobalSceneRouterProtocol
    public static var _defaultInstance: InstanceProtocol?
    public static let doesReinstantiate = false

    public static func defaultInstance() -> InstanceProtocol {
        if let instance = _defaultInstance {
            return instance
        } else {
            fatalError("The shared instance of `\(stringType(Self.self))` should have been set by this time from the main app module")
        }
    }

}
