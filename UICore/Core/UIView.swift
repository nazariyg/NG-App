// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

extension UIView {

    var baseViewController: UIViewControllerBase? {
        var baseVC: UIViewControllerBase?
        var currentResponder: UIResponder = self
        while true {
            guard let nextResponder = currentResponder.next else { break }
            guard !(nextResponder is UIWindow) else { break }
            if let vc = nextResponder as? UIViewControllerBase {
                baseVC = vc
                break
            }
            currentResponder = nextResponder
        }
        return baseVC
    }

}
