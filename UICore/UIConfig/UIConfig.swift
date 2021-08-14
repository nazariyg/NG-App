// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones

public struct UIConfig {

    // Colors

    public static let appWindowBackgroundColor = UIColor("#000800")

    public static let foregroundColor = UIColor("#d0d0d0")
    public static let darkerForegroundColor = UIColor("#a0a0a0")
    public static let disabledForegroundColor = foregroundColor.withAlphaComponent(0.33)
    public static let textPlaceholderColor = darkerForegroundColor.withAlphaComponent(0.33)
    public static let screenDefaultBackgroundColor = UIColor("#202020")

    public static let controlColor = UIColor("#404040")
    public static let controlColorBrighter = UIColor("#565656")
    public static let controlSecondaryBackgroundColor = UIColor("#404040")

    // Global font
    public static let fontKerning: CGFloat = 1

    // UI controls

    // Button
    public static let buttonTitleFont: UIFont = .mainBold(20)
    public static let buttonTitleKerning: CGFloat = 1.5
    public static let buttonTitleIsUppercased = true

    // Rounded button
    public static let roundedButtonFillColor = controlColor
    public static let roundedButtonHighlightedFillColor = controlColorBrighter
    public static let roundedButtonLineColor = UIColor("#ff8c00").withAlphaComponent(0.66)
    public static let roundedButtonLineWidth: CGFloat = s(3)
    public static let roundedButtonCornerRadius: CGFloat = s(10)
    public static let roundedButtonHorizontalPadding: CGFloat = 16
    public static let roundedButtonVerticalPadding: CGFloat = 16
    public static let roundedButtonDefaultHeight = s(56)

    // Circle button
    public static let circleButtonFillColor = controlColor
    public static let circleButtonLineColor = UIColor("#ff8c00").withAlphaComponent(0.75)
    public static let circleButtonLineWidth: CGFloat = s(3)
    public static let circleButtonSide = s(56)
    public static let circleButtonAlphaAgainstSolidBackground: CGFloat = 0.75
    public static let iconButtonDisabledBackgroundColor = controlColor.withAlphaComponent(0.66)

    // Navigation bar
    public static let navigationBarBackgroundColor = UIColor("#404040")
    public static let navigationBarTitleFont = UIFont.mainBold(22)
    public static let navigationBarTitleKerning: CGFloat = 2
    public static let navigationBarTitleColor = foregroundColor
    public static let navigationBarTitleIsUppercased = true
    public static let navigationBarShadowSize = s(12)
    public static let navigationBarShadowAlpha: CGFloat = 0.33
    public static let navigationBarShadowColor: UIColor = UIColor("#000000")

    // Splash screen
    public static let splashScreenHidingAnimationDuration: TimeInterval = 0.66
    public static let splashScreenHidingDelay: TimeInterval = 1
    public static let splashScreenHidingShadowSize = s(20)
    public static let splashScreenHidingShadowOpacity: CGFloat = 0.9
    public static let splashScreenHidingPreviousScreenInitialScale: CGFloat = 0.95

}
