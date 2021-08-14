// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

public final class UIRoundedTextField: UIStyledTextField {

    public static let overridingDefaultHorizontalPadding: CGFloat = 16
    public static let defaultBackgroundColor: UIColor = UIConfig.controlSecondaryBackgroundColor
    public static let defaultBackgroundCornerRadius: CGFloat = 8

    private static let borderLineWidth = s(2)
    private static let borderLineColor = UIConfig.controlColor.withAlphaComponent(0.2)

    private let backgroundCornerRadius: CGFloat

    public init(
        horizontalPadding: CGFloat = overridingDefaultHorizontalPadding,
        verticalPadding: CGFloat = defaultVerticalPadding,
        backgroundColor: UIColor = defaultBackgroundColor,
        backgroundCornerRadius: CGFloat = defaultBackgroundCornerRadius) {

        self.backgroundCornerRadius = s(backgroundCornerRadius)

        super.init(horizontalPadding: horizontalPadding, verticalPadding: verticalPadding)

        self.backgroundColor = backgroundColor
        roundCorners(radius: backgroundCornerRadius)
        setBorder(width: Self.borderLineWidth, color: Self.borderLineColor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

}
