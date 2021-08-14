// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import UIKit
import Core
import RxSwift

public protocol UISceneBase {
    var sceneIsInitialized: O<Bool> { get }
    var viewController: UIViewController { get }
}

/// Represents a scene for which no input parameters will ever be required.
public protocol UIInitialScene: UISceneBase {
    init()
}

/// Represents a scene for which some input parameters are required or may be required in the future.
public protocol UIScene: UISceneBase {
    associatedtype Parameters
    init(parameters: Parameters?)
}
