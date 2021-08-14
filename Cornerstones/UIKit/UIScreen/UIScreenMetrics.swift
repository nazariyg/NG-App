// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

/// See `UIScreenMetrics.adjustedPointsPhone`.
public func screenify(_ points: CGFloat) -> CGFloat {
    return UIScreenMetrics.screenify(points)
}

public func s(_ points: CGFloat) -> CGFloat {
    return screenify(points)
}

public func screenify(_ points: CGFloat, min: CGFloat) -> CGFloat {
    return UIScreenMetrics.screenify(points, min: min)
}

public func screenify(_ points: CGFloat, max: CGFloat) -> CGFloat {
    return UIScreenMetrics.screenify(points, max: max)
}

public func screenifyNano(_ points: CGFloat) -> CGFloat {
    return UIScreenMetrics.screenifyNano(points)
}

public struct UIScreenMetrics {

    // MARK: - Points adjustment

    private struct ReferenceScreenPhone {  // iPhone X/XS
        static let pointInches: CGFloat = 0.006550218340611353
        static let widthInches: CGFloat = 2.456331877729257800
    }

    private static let pointsAdjustmentCurveExponent: CGFloat = 1.25

    /// See `adjustedPointsPhone`.
    public static func screenify(_ points: CGFloat) -> CGFloat {
        if UIDevice.current.isPhone {
            return adjustedPointsPhone(points)
        }

        assertionFailure()
        return points
    }

    /// See `adjustedPointsPhone`.
    public static func screenify(_ points: CGFloat, min: CGFloat) -> CGFloat {
        if UIDevice.current.isPhone {
            return max(adjustedPointsPhone(points), min)
        }

        assertionFailure()
        return points
    }

    /// See `adjustedPointsPhone`.
    public static func screenify(_ points: CGFloat, max: CGFloat) -> CGFloat {
        if UIDevice.current.isPhone {
            return min(adjustedPointsPhone(points), max)
        }

        assertionFailure()
        return points
    }

    /// Same but without ceiling the result.
    public static func screenifyNano(_ points: CGFloat) -> CGFloat {
        if UIDevice.current.isPhone {
            return adjustedPointsPhoneNano(points)
        }

        assertionFailure()
        return points
    }

    /// For iPhones, makes the given value in points smaller for screens smaller than the reference screen and larger for larger screens.
    /// The reference screen gravitates to the middle of the screen size spectrum, e.g. iPhone XS reference screen in comparison to SE and XS Max.
    /// The formula takes into account how many inches a point represents on the reference screen and on the current screen and, as most appropriate
    /// for iPhones, the ratio of the physical screen widths of the two. For the current screen being the reference screen, the output equals the input.
    public static func adjustedPointsPhone(_ points: CGFloat) -> CGFloat {
        let adjustedPoints = ceil(points*pointsAdjustmentCoefficientPhone)
        return adjustedPoints
    }

    /// Same but without ceiling the result.
    public static func adjustedPointsPhoneNano(_ points: CGFloat) -> CGFloat {
        let adjustedPoints = points*pointsAdjustmentCoefficientPhone
        return adjustedPoints
    }

    // MARK: - Private

    private static var pointsAdjustmentCoefficientPhone: CGFloat = {
        let linearCoefficient = (ReferenceScreenPhone.pointInches/currentPointInches)*(currentWidthInches/ReferenceScreenPhone.widthInches)
        return pow(linearCoefficient, pointsAdjustmentCurveExponent)
    }()

    private static var currentPointInches: CGFloat = {
        return inches(fromPoints: 1)
    }()

    private static var currentWidthInches: CGFloat = {
        assert(UIDevice.current.hasNativeScreen)
        let pixelsPerInch = CGFloat(UIDevice.current.pixelsPerInch)
        let width = UIScreen.main.nativeBounds.size.width/pixelsPerInch
        return width
    }()

    private static var currentHeightInches: CGFloat = {
        assert(UIDevice.current.hasNativeScreen)
        let pixelsPerInch = CGFloat(UIDevice.current.pixelsPerInch)
        let height = UIScreen.main.nativeBounds.size.height/pixelsPerInch
        return height
    }()

    private static func inches(fromPoints points: CGFloat) -> CGFloat {
        assert(UIDevice.current.hasNativeScreen)
        let pixelsPerInch = CGFloat(UIDevice.current.pixelsPerInch)
        let inches = (points*UIScreen.main.nativeScale)/pixelsPerInch
        return inches
    }

}
