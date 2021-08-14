// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UIViewController {

    static var topViewController: UIViewController? {
        if let rootViewController = UIApplication.shared.firstKeyWindow?.rootViewController {
            var viewController = rootViewController
            while viewController.presentedViewController != nil {
                viewController = viewController.presentedViewController!
            }
            return viewController
        } else {
            return nil
        }
    }

    var containsCurrentFirstResponder: Bool {
        if let currentFirstResponder = UIResponder.current {
            var responder = currentFirstResponder
            while true {
                if self === responder {
                    return true
                }
                if let nextResponder = responder.next {
                    responder = nextResponder
                } else {
                    break
                }
            }
        }
        return false
    }

}
