// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UITextField {

    var textOrEmptyString: String {
        return text ?? ""
    }

    var kerning: CGFloat {
        get {
            return (defaultTextAttributes[.kern] as? CGFloat) ?? 0
        }

        set(value) {
            defaultTextAttributes.updateValue(value, forKey: .kern)
        }
    }

}
