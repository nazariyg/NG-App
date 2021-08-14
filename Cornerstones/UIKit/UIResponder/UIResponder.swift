// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UIResponder {

    private weak static var currentFirstResponder: UIResponder?

    static var current: UIResponder? {
        UIResponder.currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
        return UIResponder.currentFirstResponder
    }

    @objc private func findFirstResponder(sender: AnyObject) {
        UIResponder.currentFirstResponder = self
    }

}
