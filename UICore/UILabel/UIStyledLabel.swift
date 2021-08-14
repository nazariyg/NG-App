// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Cartography

open class UIStyledLabel: UILabelBase {

    public static let defaultBackgroundColor = UIConfig.controlSecondaryBackgroundColor.withAlphaComponent(0.66)
    public static let defaultBackgroundPadding = s(16)
    public static let defaultBackgroundCornerRadius = s(16)

    private static let styledShadowSizeFactor: CGFloat = 0.033
    private static let styledShadowMaxSize: CGFloat = 1.5
    private static let styledShadowOpacityFactor: CGFloat = 0.9
    private static let glowSize = s(16)

    private let _backgroundColor: UIColor?
    private let backgroundPaddingInsets: UIEdgeInsets?
    private let backgroundCornerRadius: CGFloat?
    private let backgroundBorderWidth: CGFloat?
    private let backgroundBorderColor: UIColor?
    private let hasShadow: Bool!
    private var shadowIsSet = false
    private var hasGlow: Bool!
    private var glowIsSet = false
    private var backgroundView: UIView?

    // MARK: - Lifecycle

    public init(
        backgroundColor: UIColor? = nil,
        backgroundPaddingInsets: UIEdgeInsets? = UIEdgeInsets(allEdgesInset: -defaultBackgroundPadding),
        backgroundCornerRadius: CGFloat? = defaultBackgroundCornerRadius,
        backgroundBorderWidth: CGFloat? = nil,
        backgroundBorderColor: UIColor? = nil,
        hasShadow: Bool = false,
        hasGlow: Bool = false) {

        assert(!(hasShadow && hasGlow), "Should be either of the two")

        _backgroundColor = backgroundColor
        self.backgroundPaddingInsets = backgroundPaddingInsets
        self.backgroundCornerRadius = backgroundCornerRadius
        self.backgroundBorderWidth = backgroundBorderWidth
        self.backgroundBorderColor = backgroundBorderColor
        self.hasShadow = hasShadow
        self.hasGlow = hasGlow

        super.init(frame: .zero)

        font = .main(UIFont.labelFontSize)
        textColor = UIConfig.foregroundColor
        kerning = UIConfig.fontKerning
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override func didMoveToSuperview() {
        addBackgroundViewIfNeeded()

        withOptional(backgroundView) {
            $0.isHidden = isHidden
            $0.alpha = alpha
        }
    }

    open override func didMoveToWindow() {
        guard window != nil else { return }

        if hasShadow && !shadowIsSet {
            setLabelShadow(ofColor: textColor)
        } else if hasGlow && !glowIsSet {
            setLabelGlow(ofColor: textColor)
        }
    }

    public func setLabelShadow(ofColor color: UIColor) {
        let shadowSize = min(Self.styledShadowSizeFactor*font.pointSize, Self.styledShadowMaxSize)
        let shadowOpacity = Self.styledShadowOpacityFactor*textColor.alphaComponent
        setShadow(ofSize: shadowSize, opacity: shadowOpacity, color: color, offset: .init(width: 0, height: shadowSize))
        shadowIsSet = true
    }

    private func setLabelGlow(ofColor color: UIColor) {
        setShadow(ofSize: Self.glowSize, opacity: 1, color: color)
        glowIsSet = true
    }

    public override func removeFromSuperview() {
        super.removeFromSuperview()
        backgroundView?.removeFromSuperview()
        backgroundView = nil
    }

    public override var isHidden: Bool {
        didSet {
            backgroundView?.isHidden = isHidden
        }
    }

    open override var alpha: CGFloat {
        didSet {
            backgroundView?.alpha = alpha
        }
    }

    private func addBackgroundViewIfNeeded() {
        guard
            let superview = superview,
            let backgroundColor = _backgroundColor,
            backgroundView == nil
        else { return }

        backgroundView?.removeFromSuperview()
        backgroundView = UIView()

        withOptional(backgroundView) {
            $0.isUserInteractionEnabled = false

            $0.backgroundColor = backgroundColor
            if let backgroundCornerRadius = backgroundCornerRadius, backgroundCornerRadius > 0 {
                $0.roundCorners(radius: backgroundCornerRadius)
            }

            superview.insertSubview($0, belowSubview: self)

            if let backgroundPaddingInsets = backgroundPaddingInsets {
                constrain($0, self) { view, superview in
                    view.edges == inset(superview.edges, backgroundPaddingInsets)
                }
            } else {
                constrain($0, self) { view, superview in
                    view.edges == superview.edges
                }
            }

            if let backgroundBorderWidth = backgroundBorderWidth,
               let backgroundBorderColor = backgroundBorderColor {

                $0.setBorder(width: backgroundBorderWidth, color: backgroundBorderColor)
            }
        }
    }

}
