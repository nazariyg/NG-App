// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import RxSwift

public class UIStyledRoundedButton: UIExtraHitAreaButton {

    private static let pressedStateBackgroundAlpha: CGFloat = 0.33
    private static let disabledBackgroundAlpha: CGFloat = 0.5
    private static let disabledLineColorAlphaFactor: CGFloat = 0.33
    private static let adjustsFontSizeToFitWidth = true
    private static let adjustingFontSizeToFitWidthMinimumScaleFactor: CGFloat = 0.1

    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat
    private let cornerRadius: CGFloat
    private let lineWidth: CGFloat
    private var isPressed = false
    private let disposeBag = DisposeBag()

    public init(
        horizontalPadding: CGFloat = UIConfig.roundedButtonHorizontalPadding,
        verticalPadding: CGFloat = UIConfig.roundedButtonVerticalPadding,
        cornerRadius: CGFloat = UIConfig.roundedButtonCornerRadius,
        lineWidth: CGFloat = UIConfig.roundedButtonLineWidth,
        lineColor: UIColor = UIConfig.roundedButtonLineColor,
        fillColor: UIColor? = UIConfig.roundedButtonFillColor,
        highlightedFillColor: UIColor? = UIConfig.roundedButtonHighlightedFillColor,
        textColor: UIColor = UIConfig.foregroundColor) {

        self.horizontalPadding = s(horizontalPadding)
        self.verticalPadding = s(verticalPadding)
        self.cornerRadius = s(cornerRadius)
        self.lineWidth = s(lineWidth)
        self.lineColor = lineColor
        self.fillColor = fillColor
        self.highlightedFillColor = highlightedFillColor
        self.textColor = textColor

        super.init(frame: .zero)

        titleLabel?.font = UIConfig.buttonTitleFont
        setTitleColor(textColor, for: .normal)
        setTitleColor(UIConfig.disabledForegroundColor, for: .disabled)
        titleKerning = UIConfig.buttonTitleKerning

        contentEdgeInsets = UIEdgeInsets(horizontalInset: horizontalPadding, verticalInset: verticalPadding)

        roundCorners(radius: cornerRadius)
        layer.borderWidth = lineWidth

        updateBackground()
        wireInTouchEvents()

        if Self.adjustsFontSizeToFitWidth {
            withOptional(titleLabel) {
                $0.adjustsFontSizeToFitWidth = true
                $0.minimumScaleFactor = Self.adjustingFontSizeToFitWidthMinimumScaleFactor
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func wireInTouchEvents() {
        rx.controlEvent(.touchDown)
            .subscribeOnNext { [weak self] _ in
                guard let self = self else { return }
                self.isPressed = true
                self.updateBackground()
            }
            .disposed(by: disposeBag)

        rx.controlEvent([.touchUpInside, .touchUpOutside, .touchCancel])
            .subscribeOnNext { [weak self] _ in
                guard let self = self else { return }
                self.isPressed = false
                self.updateBackground()
            }
            .disposed(by: disposeBag)
    }

    public override var isEnabled: Bool {
        didSet {
            setNeedsDisplay()
            updateBackground()
        }
    }

    public var lineColor: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }

    public var fillColor: UIColor? {
        didSet {
            updateBackground()
        }
    }

    public var highlightedFillColor: UIColor? {
        didSet {
            updateBackground()
        }
    }

    public var textColor: UIColor {
        didSet {
            setNeedsDisplay()
        }
    }

    public override func draw(_ rect: CGRect) {
        if isEnabled {
            borderUIColor = lineColor

            if let attributedTitle = attributedTitle(for: .normal) {
                let attributedString = NSMutableAttributedString(attributedString: attributedTitle)
                attributedString.addAttribute(
                    .foregroundColor, value: textColor,
                    range: NSRange(location: 0, length: attributedString.length))
                setAttributedTitle(attributedString, for: .normal)
            }
        } else {
            borderUIColor = lineColor.withAlphaComponent(lineColor.alphaComponent*Self.disabledLineColorAlphaFactor)

            if let attributedTitle = attributedTitle(for: .disabled) {
                let attributedString = NSMutableAttributedString(attributedString: attributedTitle)
                attributedString.addAttribute(
                    .foregroundColor, value: UIConfig.disabledForegroundColor,
                    range: NSRange(location: 0, length: attributedString.length))
                setAttributedTitle(attributedString, for: .disabled)
            }
        }
    }

    private func updateBackground() {
        if !isPressed {
            if let fillColor = fillColor {
                if isEnabled {
                    backgroundColor = fillColor
                } else {
                    backgroundColor = fillColor.withAlphaComponent(Self.disabledBackgroundAlpha)
                }
            } else {
                backgroundColor = nil
            }
        } else {
            if let highlightedFillColor = highlightedFillColor {
                backgroundColor = highlightedFillColor
            } else {
                backgroundColor = lineColor.withAlphaComponent(lineColor.alphaComponent*Self.pressedStateBackgroundAlpha)
            }
        }
    }

}
