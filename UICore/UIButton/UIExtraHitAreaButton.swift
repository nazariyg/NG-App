// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

public class UIExtraHitAreaButton: UIButtonBase {

    public var extraHitMargin: CGFloat = s(0)

    // MARK: - Lifecycle

    public convenience init(padding: CGFloat) {
        self.init(frame: .zero)
        extraHitMargin = padding
    }

    // MARK: - Hit testing

    public override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        let hitArea = bounds.insetBy(dx: -extraHitMargin, dy: -extraHitMargin)
        return hitArea.contains(point)
    }

}
