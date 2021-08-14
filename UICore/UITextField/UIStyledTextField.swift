// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones

public class UIStyledTextField: UITextField, UITextFieldDelegate {

    public static let defaultHorizontalPadding: CGFloat = 16
    public static let defaultVerticalPadding: CGFloat = 6
    public static let sideImagePadding: CGFloat = 2
    public static let sideLabelPadding: CGFloat = 8
    public static let sideLabelFontSizeRatio: CGFloat = 0.8

    public var clearButtonTintColor: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }

    public var clearButtonExtraHorizontalOffset: CGFloat? {
        didSet {
            setNeedsLayout()
        }
    }

    public var maxCharacterCount: Int?

    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat

    public init(
        horizontalPadding: CGFloat = defaultHorizontalPadding,
        verticalPadding: CGFloat = defaultVerticalPadding) {

        self.horizontalPadding = s(horizontalPadding)
        self.verticalPadding = s(verticalPadding)

        super.init(frame: .zero)

        font = .main(UIFont.labelFontSize)
        textColor = UIConfig.foregroundColor
        tintColor = UIConfig.foregroundColor
        kerning = UIConfig.fontKerning

        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    public override var font: UIFont? {
        didSet {
            if let placeholderText = placeholder {
                updatePlaceholderStyle(text: placeholderText)
            }
        }
    }

    public override var placeholder: String? {
        didSet {
            if let placeholderText = placeholder {
                updatePlaceholderStyle(text: placeholderText)
            } else {
                attributedPlaceholder = nil
            }
        }
    }

    private func updatePlaceholderStyle(text: String) {
        attributedPlaceholder =
            NSAttributedString(
                string: text,
                attributes: [
                    .font: font ?? UIFont.main(UIFont.labelFontSize),
                    .foregroundColor: UIConfig.textPlaceholderColor,
                    .kern: UIConfig.fontKerning
                ])
    }

    public var leftPaddingImage: UIImage? {
        didSet {
            guard let leftPaddingImage = leftPaddingImage else {
                leftView = nil
                leftViewMode = .never
                return
            }

            let imageHorizontalPadding = s(Self.sideImagePadding)

            let imageSize = leftPaddingImage.size

            let containerFrame = CGRect(origin: .zero, size: CGSize(width: imageSize.width + 2*imageHorizontalPadding, height: imageSize.height))
            let containerView = UIView(frame: containerFrame)

            let imageViewFrame = CGRect(origin: CGPoint(x: imageHorizontalPadding, y: 0), size: imageSize)
            let imageView = UIImageView(frame: imageViewFrame)
            imageView.contentMode = .scaleAspectFit
            imageView.image = leftPaddingImage
            imageView.tintColor = UIConfig.foregroundColor
            containerView.addSubview(imageView)

            leftView = containerView
            leftViewMode = .always
        }
    }

    public func setLeftPaddingImage(_ image: UIImage?, padding: CGFloat = sideImagePadding, tintColor: UIColor? = nil) {
        guard let leftPaddingImage = image else {
            leftView = nil
            leftViewMode = .never
            return
        }

        let imageHorizontalPadding = s(padding)

        let imageSize = leftPaddingImage.size

        let containerFrame = CGRect(origin: .zero, size: CGSize(width: imageSize.width + 2*imageHorizontalPadding, height: imageSize.height))
        let containerView = UIView(frame: containerFrame)

        let imageViewFrame = CGRect(origin: CGPoint(x: imageHorizontalPadding, y: 0), size: imageSize)
        let imageView = UIImageView(frame: imageViewFrame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = leftPaddingImage
        imageView.tintColor = tintColor ?? UIConfig.foregroundColor
        containerView.addSubview(imageView)

        leftView = containerView
        leftViewMode = .always
    }

    public var rightPaddingImage: UIImage? {
        didSet {
            guard let rightPaddingImage = rightPaddingImage else {
                rightView = nil
                rightViewMode = .never
                return
            }

            let imageHorizontalPadding = s(Self.sideImagePadding)

            let imageSize = rightPaddingImage.size

            let containerFrame = CGRect(origin: .zero, size: CGSize(width: imageSize.width + 2*imageHorizontalPadding, height: imageSize.height))
            let containerView = UIView(frame: containerFrame)

            let imageViewFrame = CGRect(origin: CGPoint(x: imageHorizontalPadding, y: 0), size: imageSize)
            let imageView = UIImageView(frame: imageViewFrame)
            imageView.contentMode = .scaleAspectFit
            imageView.image = rightPaddingImage
            imageView.tintColor = UIConfig.foregroundColor
            containerView.addSubview(imageView)

            rightView = containerView
            rightViewMode = .always
        }
    }

    public func setRightPaddingImage(_ image: UIImage?, padding: CGFloat = sideImagePadding, tintColor: UIColor? = nil) {
        guard let rightPaddingImage = image else {
            rightView = nil
            rightViewMode = .never
            return
        }

        let imageHorizontalPadding = s(padding)

        let imageSize = rightPaddingImage.size

        let containerFrame = CGRect(origin: .zero, size: CGSize(width: imageSize.width + 2*imageHorizontalPadding, height: imageSize.height))
        let containerView = UIView(frame: containerFrame)

        let imageViewFrame = CGRect(origin: CGPoint(x: imageHorizontalPadding, y: 0), size: imageSize)
        let imageView = UIImageView(frame: imageViewFrame)
        imageView.contentMode = .scaleAspectFit
        imageView.image = rightPaddingImage
        imageView.tintColor = tintColor ?? UIConfig.foregroundColor
        containerView.addSubview(imageView)

        rightView = containerView
        rightViewMode = .always
    }

    public var leftPaddingText: String? {
        didSet {
            guard let leftPaddingText = leftPaddingText else {
                leftView = nil
                leftViewMode = .never
                return
            }

            let label = UILabel()
            label.font = .main(UIFont.labelFontSize*Self.sideLabelFontSizeRatio)
            label.textColor = UIConfig.foregroundColor
            label.text = leftPaddingText
            label.sizeToFit()

            let labelHorizontalPadding = s(Self.sideLabelPadding)

            let containerFrame = CGRect(origin: .zero, size: CGSize(width: label.frame.width + 2*labelHorizontalPadding, height: label.frame.height))
            let containerView = UIView(frame: containerFrame)
            label.frame.origin.x = labelHorizontalPadding
            containerView.addSubview(label)

            leftView = containerView
            leftViewMode = .always
        }
    }

    public var leftPaddingLabel: UILabel? {
        didSet {
            guard let leftPaddingLabel = leftPaddingLabel else {
                leftView = nil
                leftViewMode = .never
                return
            }

            let labelHorizontalPadding = s(Self.sideLabelPadding)

            let containerFrame =
                CGRect(origin: .zero, size: CGSize(width: leftPaddingLabel.frame.width + 2*labelHorizontalPadding, height: leftPaddingLabel.frame.height))
            let containerView = UIView(frame: containerFrame)
            leftPaddingLabel.frame.origin.x = labelHorizontalPadding
            containerView.addSubview(leftPaddingLabel)

            leftView = containerView
            leftViewMode = .always
        }
    }

    public var rightPaddingText: String? {
        didSet {
            guard let rightPaddingText = rightPaddingText else {
                rightView = nil
                rightViewMode = .never
                return
            }

            let label = UILabel()
            label.font = .main(UIFont.labelFontSize*Self.sideLabelFontSizeRatio)
            label.textColor = UIConfig.foregroundColor
            label.text = rightPaddingText
            label.sizeToFit()

            let labelHorizontalPadding = s(Self.sideLabelPadding)

            let containerFrame = CGRect(origin: .zero, size: CGSize(width: label.frame.width + 2*labelHorizontalPadding, height: label.frame.height))
            let containerView = UIView(frame: containerFrame)
            label.frame.origin.x = labelHorizontalPadding
            containerView.addSubview(label)

            rightView = containerView
            rightViewMode = .always
        }
    }

    public var rightPaddingLabel: UILabel? {
        didSet {
            guard let rightPaddingLabel = rightPaddingLabel else {
                rightView = nil
                rightViewMode = .never
                return
            }

            let labelHorizontalPadding = s(Self.sideLabelPadding)

            let containerFrame =
                CGRect(origin: .zero, size: CGSize(width: rightPaddingLabel.frame.width + 2*labelHorizontalPadding, height: rightPaddingLabel.frame.height))
            let containerView = UIView(frame: containerFrame)
            rightPaddingLabel.frame.origin.x = labelHorizontalPadding
            containerView.addSubview(rightPaddingLabel)

            rightView = containerView
            rightViewMode = .always
        }
    }

    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        let leftPadding = leftView?.frame.width ?? horizontalPadding
        let rightPadding = rightView?.frame.width ?? horizontalPadding
        return bounds.inset(by: UIEdgeInsets(top: verticalPadding, left: leftPadding, bottom: verticalPadding, right: rightPadding))
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    public override func didMoveToSuperview() {
        if keyboardAppearance == .default, let baseKeyboardAppearance = baseViewController?.keyboardAppearance {
            keyboardAppearance = baseKeyboardAppearance
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateClearButtonColorIfNeeded()
    }

    private func updateClearButtonColorIfNeeded() {
        if let clearButtonTintColor = clearButtonTintColor {
            for subview in subviews {
                if let button = subview as? UIButton {
                    if let templateImage = button.image(for: .normal)?.withRenderingMode(.alwaysTemplate) {
                        button.setImage(templateImage, for: .normal)
                        button.setImage(templateImage, for: .highlighted)
                        button.tintColor = clearButtonTintColor
                    }
                    break
                }
            }
        }
    }

    public override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        if let clearButtonExtraHorizontalOffset = clearButtonExtraHorizontalOffset {
            rect = rect.offsetBy(dx: -s(clearButtonExtraHorizontalOffset), dy: 0)
        }
        return rect
    }

    // MARK: - UITextFieldDelegate

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let maxCharacterCount = maxCharacterCount else { return true }

        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= maxCharacterCount
    }

}
