// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public enum InitialSceneKind {
    case scene(sceneType: UIInitialScene.Type)
    case tabs(tabsControllerType: UITabsController.Type, tabSceneTypes: [UIInitialScene.Type], initialTabIndex: Int)
}
