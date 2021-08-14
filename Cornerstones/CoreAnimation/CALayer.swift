// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension CALayer {

    // MARK: - Attributes

    var borderUIColor: UIColor? {
        get {
            return borderColor.map { UIColor(cgColor: $0) }
        }

        set(color) {
            borderColor = color?.cgColor
        }
    }

    var backgroundUIColor: UIColor? {
        get {
            return backgroundColor.map { UIColor(cgColor: $0) }
        }

        set(color) {
            backgroundColor = color?.cgColor
        }
    }

    func setShadow(ofSize size: CGFloat, opacity: CGFloat, color: UIColor = .black, offset: CGSize = .zero) {
        shadowColor = UIColor.black.cgColor
        shadowRadius = size
        shadowOpacity = Float(opacity)
        shadowColor = color.cgColor
        shadowOffset = offset
    }

    func setRoundedShadow(forBounds bounds: CGRect, cornerRadius: CGFloat, size: CGFloat, opacity: CGFloat, color: UIColor = .black, offset: CGSize = .zero) {
        shadowColor = UIColor.black.cgColor
        shadowRadius = size
        shadowOpacity = Float(opacity)
        shadowColor = color.cgColor
        shadowOffset = offset
        shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }

    func roundCorners(radius: CGFloat) {
        cornerRadius = radius
        masksToBounds = true
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        mask = maskLayer
    }

    func sharpenCorners() {
        cornerRadius = 0
        masksToBounds = false
    }

    func setBorder(width: CGFloat, color: UIColor) {
        borderWidth = width
        borderColor = color.cgColor
    }

}

public extension UIView {

    // MARK: - Attributes

    var borderUIColor: UIColor? {
        get {
            return layer.borderUIColor
        }

        set(color) {
            layer.borderUIColor = color
        }
    }

    func setShadow(ofSize size: CGFloat, opacity: CGFloat, color: UIColor = .black, offset: CGSize = .zero) {
        layer.setShadow(ofSize: size, opacity: opacity, color: color, offset: offset)
    }

    func setRoundedShadow(forBounds bounds: CGRect, cornerRadius: CGFloat, size: CGFloat, opacity: CGFloat, color: UIColor = .black, offset: CGSize = .zero) {
        layer.setRoundedShadow(forBounds: bounds, cornerRadius: cornerRadius, size: size, opacity: opacity, color: color, offset: offset)
    }

    func roundCorners(radius: CGFloat) {
        layer.roundCorners(radius: radius)
    }

    func sharpenCorners() {
        layer.sharpenCorners()
    }

    func setBorder(width: CGFloat, color: UIColor) {
        layer.setBorder(width: width, color: color)
    }

}
