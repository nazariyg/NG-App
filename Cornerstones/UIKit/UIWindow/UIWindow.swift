// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

open class UIPassthroughWindow: UIWindow {

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains {
            !$0.isHidden && $0.point(inside: convert(point, to: $0), with: event)
        }
    }

}
