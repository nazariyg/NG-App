// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UIEdgeInsets {

    init(allEdgesInset: CGFloat) {
        self.init(top: allEdgesInset, left: allEdgesInset, bottom: allEdgesInset, right: allEdgesInset)
    }

    init(horizontalInset: CGFloat = 0, verticalInset: CGFloat = 0) {
        self.init(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }

}
