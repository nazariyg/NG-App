// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UIApplication {

    var firstKeyWindow: UIWindow? {
        return windows.first(where: { $0.isKeyWindow })
    }

}
