// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public protocol UITabsControllerBase: AnyObject {}

public protocol UITabsController: UITabsControllerBase {
    init()
    var viewControllers: [UIViewController]? { get set }
    var selectedIndex: Int { get set }
    func showTabBar()
    func hideTabBar()
}
