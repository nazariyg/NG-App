// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

class UIEmbeddingNavigationController: UIStyledNavigationController {

    // MARK: - Lifecycle

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        isNavigationBarHidden = true
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

}

// MARK: - UINavigationBarDelegate

extension UIEmbeddingNavigationController: UINavigationBarDelegate {

    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        UIScener.shared._popSceneIfNeeded(ifContainsNavigationItem: item)
        popViewController(animated: true)
        return true
    }

}
