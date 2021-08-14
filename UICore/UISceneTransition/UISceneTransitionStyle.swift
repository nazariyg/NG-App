// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public enum UISceneTransitionStyle {

    case system
    case defaultNext
    case defaultUp
    case defaultSet
    case setAfterSplashScreen
    case immediateSet

    public var transition: UISceneTransition? {
        switch self {

        case .system:
            return nil

        case .defaultNext:
            return
                UISceneTransition(
                    animationControllerForPresentationType: UINextSceneTransitionAnimationController.self,
                    animationControllerForDismissalType: UINextSceneTransitionAnimationController.self)

        case .defaultUp:
            return
                UISceneTransition(
                    animationControllerForPresentationType: UIUpSceneTransitionAnimationController.self,
                    animationControllerForDismissalType: UIUpSceneTransitionAnimationController.self)

        case .defaultSet:
            let animation =
                UISceneTransition.ChildViewControllerReplacementAnimation(
                    duration: 0.33, options: .transitionCrossDissolve)
            return UISceneTransition(childViewControllerReplacementAnimation: animation)

        case .setAfterSplashScreen:
            let animation =
                UISceneTransition.ChildViewControllerReplacementAnimation(
                    duration: UIConfig.splashScreenHidingAnimationDuration, options: .curveEaseOut, delay: UIConfig.splashScreenHidingDelay)
            return UISceneTransition(childViewControllerReplacementAnimation: animation)

        case .immediateSet:
            return nil

        }

    }

    public var isNext: Bool {
        switch self {

        case .defaultNext:
            return true

        default:
            return false

        }
    }

    public var isUp: Bool {
        switch self {

        case .defaultUp:
            return true

        default:
            return false

        }
    }

    public var affectsEntireScreen: Bool {
        switch self {

        case .defaultNext:
            return false

        default:
            return true

        }
    }

}
