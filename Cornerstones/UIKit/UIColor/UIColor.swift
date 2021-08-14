// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UIColor {

    /// Constructs UIColor instances from a hex strings like "rrggbb", "#rrggbb", "rrggbbaa", "#rrggbbaa".
    convenience init(_ hex: String) {
        var hex = hex.trimmed()
        hex = hex.replacingOccurrences(of: "^#", with: "", options: .regularExpression)

        assert(
            hex.count % 2 == 0 && (hex.count/2 == 3 || hex.count/2 == 4),
            "The hex string must contain either 3 or 4 color components")

        guard var intHex = UInt(hex, radix: 16) else {
            assertionFailure("The hex string must be a valid hexadecimal number")
            self.init(intHex: 0)
            return
        }

        let hasAlpha = hex.count > 6
        if !hasAlpha {
            self.init(intHex: intHex)
        } else {
            let alpha = UInt8(intHex & 0xff)
            intHex >>= 8
            self.init(intHex: intHex, alpha: alpha)
        }
    }

    convenience init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = 255) {
        self.init(
            red: CGFloat(red)/255,
            green: CGFloat(green)/255,
            blue: CGFloat(blue)/255,
            alpha: CGFloat(alpha)/255)
    }

    convenience init(intHex: UInt, alpha: UInt8 = 255) {
        assert(0...0xffffff ~= intHex, "The input is out of bounds")

        self.init(
            red: UInt8((intHex >> 16) & 0xff),
            green: UInt8((intHex >> 8) & 0xff),
            blue: UInt8(intHex & 0xff),
            alpha: alpha
        )
    }

}

public extension UIColor {

    var redComponent: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return red
        } else {
            assertionFailure()
            return 0
        }
    }

    var greenComponent: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return green
        } else {
            assertionFailure()
            return 0
        }
    }

    var blueComponent: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return blue
        } else {
            assertionFailure()
            return 0
        }
    }

    var alphaComponent: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return alpha
        } else {
            if cgColor.pattern == nil {
                assertionFailure()
                return 0
            } else {
                // A pattern-based color.
                return 1
            }
        }
    }

    func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red: red, green: green, blue: blue, alpha: alpha)
        } else {
            assertionFailure()
            return (red: 0, green: 0, blue: 0, alpha: 0)
        }
    }

}

public extension UIColor {

    func brighter(by delta: CGFloat) -> UIColor {
        assert(delta >= 0)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            assertionFailure()
            return .clear
        }
        brightness = min(brightness + delta, 1)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    func darker(by delta: CGFloat) -> UIColor {
        assert(delta >= 0)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            assertionFailure()
            return .clear
        }
        brightness = max(brightness - delta, 0)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

}
