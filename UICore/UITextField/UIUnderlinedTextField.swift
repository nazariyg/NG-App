// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

public final class UIUnderlinedTextField: UIStyledTextField {

    public static let overridingDefaultHorizontalPadding: CGFloat = 4
    public static let defaultUnderlineColor: UIColor = UIConfig.foregroundColor
    public static let defaultUnderlineWidth: CGFloat = 3

    private let underlineColor: UIColor
    private let underlineWidth: CGFloat

    // MARK: - Lifecycle

    public init(
        horizontalPadding: CGFloat = overridingDefaultHorizontalPadding,
        verticalPadding: CGFloat = defaultVerticalPadding,
        underlineColor: UIColor = defaultUnderlineColor,
        underlineWidth: CGFloat = defaultUnderlineWidth) {

        self.underlineColor = underlineColor
        self.underlineWidth = s(underlineWidth)

        super.init(horizontalPadding: horizontalPadding, verticalPadding: verticalPadding)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Appearance

    public override func layerWillDraw(_ layer: CALayer) {
        super.layerWillDraw(layer)

        let sideViewAlpha: CGFloat
        if !isFirstResponder {
            sideViewAlpha = 0.5
        } else {
            sideViewAlpha = 1
        }
        leftView?.alpha = sideViewAlpha
        rightView?.alpha = sideViewAlpha
    }

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let size = bounds.size

        let color: UIColor
        if !isFirstResponder {
            color = underlineColor.withAlphaComponent(0.5)
        } else {
            color = underlineColor
        }

        let rect = CGRect(x: 0, y: size.height - underlineWidth, width: size.width, height: underlineWidth)

        context.setFillColor(color.cgColor)
        context.fill(rect)
    }

    public override func becomeFirstResponder() -> Bool {
        setNeedsDisplay()
        return super.becomeFirstResponder()
    }

    public override func resignFirstResponder() -> Bool {
        setNeedsDisplay()
        return super.resignFirstResponder()
    }

}
