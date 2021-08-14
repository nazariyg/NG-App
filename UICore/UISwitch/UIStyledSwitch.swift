// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

public class UIStyledSwitch: UISwitch {

    public static let scale: CGFloat = 1.15

    private static let thumbColor = UIConfig.foregroundColor
    private static let offStateBackgroundColor = UIConfig.controlSecondaryBackgroundColor
    private static let onStateBackgroundColor = UIConfig.controlColor

    // MARK: - Lifecycle

    public convenience init() {
        self.init(frame: .zero)

        backgroundColor = Self.offStateBackgroundColor
        onTintColor = Self.onStateBackgroundColor
        thumbTintColor = Self.thumbColor

        transform = CGAffineTransform(scaleX: Self.scale, y: Self.scale)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(radius: bounds.height/2)
    }

}
