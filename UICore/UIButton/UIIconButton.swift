// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import RxSwift
import Cartography

public class UIIconButton: UIExtraHitAreaButton {

    public enum IconAlignmentMode {
        case center
        case left
        case right
        case top
        case bottom
    }

    public static let defaultIconPadding: CGFloat = 0
    public static let defaultFillColor: UIColor? = nil
    public static let defaultLineColor: UIColor? = nil
    public static let defaultLineWidth: CGFloat = 1.5
    public static let defaultIconTintColor = UIConfig.foregroundColor
    public static let defaultDisabledIconTintColor = UIConfig.disabledForegroundColor
    public static let defaultDisabledFillColor = UIConfig.iconButtonDisabledBackgroundColor
    public static let defaultDisabledLineColor = UIConfig.disabledForegroundColor
    public static let defaultIconAlignmentMode: IconAlignmentMode = .center

    private static let pressedStateIconAlpha: CGFloat = 0.5

    fileprivate let iconPadding: CGFloat
    fileprivate let fillColor: UIColor?
    fileprivate let lineColor: UIColor?
    fileprivate let lineWidth: CGFloat
    fileprivate let disabledIconTintColor: UIColor
    fileprivate let disabledFillColor: UIColor
    fileprivate let disabledLineColor: UIColor
    fileprivate let iconAlignmentMode: IconAlignmentMode
    fileprivate let allowPressedState: Bool
    private let circleView: UIIconCircleButtonCircleView
    private let iconImageView: UIImageView
    private var isPressed = false
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    public init(
        iconPadding: CGFloat = defaultIconPadding,
        fillColor: UIColor? = defaultFillColor,
        lineColor: UIColor? = defaultLineColor,
        lineWidth: CGFloat = defaultLineWidth,
        iconTintColor: UIColor = defaultIconTintColor,
        disabledIconTintColor: UIColor = defaultDisabledIconTintColor,
        disabledFillColor: UIColor = defaultDisabledFillColor,
        disabledLineColor: UIColor = defaultDisabledLineColor,
        iconAlignmentMode: IconAlignmentMode = defaultIconAlignmentMode,
        allowGlow: Bool = true,
        allowPressedState: Bool = true) {

        self.iconPadding = s(iconPadding)
        self.fillColor = fillColor
        self.lineColor = lineColor
        self.lineWidth = s(lineWidth)
        self.iconTintColor = iconTintColor
        self.disabledIconTintColor = disabledIconTintColor
        self.disabledFillColor = disabledFillColor
        self.disabledLineColor = disabledLineColor
        self.iconAlignmentMode = iconAlignmentMode
        self.allowPressedState = allowPressedState

        circleView = UIIconCircleButtonCircleView()

        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFit

        super.init(frame: .zero)

        circleView.button = self
        withOptional(self, circleView) {
            $1.backgroundColor = .clear
            $1.isUserInteractionEnabled = false
            $0.addSubview($1)

            constrain($1, $0) { view, superview in
                view.edges == superview.edges
            }
        }

        withOptional(self, iconImageView) {
            $0.addSubview($1)
            $1.tintColor = iconTintColor
            $1.translatesAutoresizingMaskIntoConstraints = false

            switch iconAlignmentMode {
            case .center:
                constrain($1, $0) { view, superview in
                    view.leading == superview.leading + iconPadding
                    view.trailing == superview.trailing - iconPadding
                    view.top == superview.top + iconPadding
                    view.bottom == superview.bottom - iconPadding
                }
            case .left:
                constrain($1, $0) { view, superview in
                    view.leading == superview.leading + iconPadding
                    view.width == view.height
                    view.top == superview.top + iconPadding
                    view.bottom == superview.bottom - iconPadding
                }
            case .right:
                constrain($1, $0) { view, superview in
                    view.width == view.height
                    view.trailing == superview.trailing - iconPadding
                    view.top == superview.top + iconPadding
                    view.bottom == superview.bottom - iconPadding
                }
            case .top:
                constrain($1, $0) { view, superview in
                    view.leading == superview.leading + iconPadding
                    view.trailing == superview.trailing - iconPadding
                    view.top == superview.top + iconPadding
                    view.height == view.width
                }
            case .bottom:
                constrain($1, $0) { view, superview in
                    view.leading == superview.leading + iconPadding
                    view.trailing == superview.trailing - iconPadding
                    view.height == view.width
                    view.bottom == superview.bottom - iconPadding
                }
            }
        }

        wireInTouchEvents()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func wireInTouchEvents() {
        rx.controlEvent(.touchDown)
            .subscribeOnNext { [weak self] _ in
                guard let self = self else { return }
                self.isPressed = true
                self.setNeedsDisplay()
            }
            .disposed(by: disposeBag)

        rx.controlEvent([.touchUpInside, .touchUpOutside, .touchCancel])
            .subscribeOnNext { [weak self] _ in
                guard let self = self else { return }
                self.isPressed = false
                self.setNeedsDisplay()
            }
            .disposed(by: disposeBag)
    }

    public var icon: UIImage? {
        get {
            return iconImageView.image
        }

        set(icon) {
            iconImageView.image = icon
        }
    }

    public var iconTintColor: UIColor = defaultIconTintColor {
        didSet {
            iconImageView.tintColor = iconTintColor
        }
    }

    public var contentTransform: CGAffineTransform = .identity {
        didSet {
            circleView.transform = contentTransform
            iconImageView.transform = contentTransform
        }
    }

    public override func layerWillDraw(_ layer: CALayer) {
        super.layerWillDraw(layer)

        if iconImageView.image?.renderingMode == .alwaysTemplate {
            if isEnabled {
                iconImageView.tintColor = iconTintColor
            } else {
                iconImageView.tintColor = disabledIconTintColor
            }
        }

        if isEnabled && allowPressedState {
            iconImageView.alpha = !isPressed ? 1 : Self.pressedStateIconAlpha
        } else {
            iconImageView.alpha = 1
        }
    }

    public override func draw(_ rect: CGRect) {
        // Empty.
    }

}

public final class UIIconCircleButtonCircleView: UIView {

    fileprivate weak var button: UIIconButton!

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let size = bounds.size

        let diameter = min(size.width, size.height)
        let circleRect = CGRect(x: (size.width - diameter)/2, y: (size.height - diameter)/2, width: diameter, height: diameter)

        if let fillColor = button.fillColor {
            let inset = button.lineWidth/2
            let fillCircleRect = circleRect.insetBy(dx: inset, dy: inset)
            let color = button.isEnabled ? fillColor : button.disabledFillColor
            context.setFillColor(color.cgColor)
            context.fillEllipse(in: fillCircleRect)
        }

        if let lineColor = button.lineColor {
            let inset = button.lineWidth
            let lineCircleRect = circleRect.insetBy(dx: inset, dy: inset)
            let color = button.isEnabled ? lineColor : button.disabledLineColor
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(button.lineWidth)
            context.strokeEllipse(in: lineCircleRect)
        }
    }

}
