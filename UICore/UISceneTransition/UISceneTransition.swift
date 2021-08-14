// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public final class UISceneTransition: NSObject {

    struct ChildViewControllerReplacementAnimation {

        let duration: TimeInterval
        let options: UIView.AnimationOptions
        let delay: TimeInterval

        init(duration: TimeInterval, options: UIView.AnimationOptions = [], delay: TimeInterval = 0) {
            self.duration = duration
            self.options = options
            self.delay = delay
        }

    }

    private(set) var animationControllerForPresentationType: UIAnimationController.Type?
    private(set) var animationControllerForDismissalType: UIAnimationController.Type?
    private(set) var presentationControllerType: UIInteractablePresentationController.Type?
    private(set) var interactionControllerForPresentationType: UIAnimatedInteractionController.Type?
    private(set) var interactionControllerForDismissalType: UIAnimatedInteractionController.Type?
    private(set) var childViewControllerReplacementAnimation: ChildViewControllerReplacementAnimation?

    private lazy var animationControllerForPresentation: UIAnimationController? = {
        return animationControllerForPresentationType?.init(isReversed: false)
    }()

    private lazy var animationControllerForDismissal: UIAnimationController? = {
        return animationControllerForDismissalType?.init(isReversed: true)
    }()

    private var presentationController: UIInteractablePresentationController?

    private lazy var interactionControllerForPresentation: UIAnimatedInteractionController? = {
        return interactionControllerForPresentationType?.init()
    }()

    private lazy var interactionControllerForDismissal: UIAnimatedInteractionController? = {
        return interactionControllerForDismissalType?.init()
    }()

    // MARK: - Lifecycle

    init(animationControllerType: UIAnimationController.Type) {
        self.animationControllerForPresentationType = animationControllerType
    }

    init(presentationControllerType: UIInteractablePresentationController.Type) {
        self.presentationControllerType = presentationControllerType
    }

    init(
        animationControllerForPresentationType: UIAnimationController.Type,
        animationControllerForDismissalType: UIAnimationController.Type) {

        self.animationControllerForPresentationType = animationControllerForPresentationType
        self.animationControllerForDismissalType = animationControllerForDismissalType
    }

    init(
        animationControllerForPresentationType: UIAnimationController.Type,
        animationControllerForDismissalType: UIAnimationController.Type,
        presentationControllerType: UIInteractablePresentationController.Type) {

        self.animationControllerForPresentationType = animationControllerForPresentationType
        self.animationControllerForDismissalType = animationControllerForDismissalType
        self.presentationControllerType = presentationControllerType
    }

    init(
        animationControllerForPresentationType: UIAnimationController.Type,
        animationControllerForDismissalType: UIAnimationController.Type,
        interactionControllerForPresentationType: UIAnimatedInteractionController.Type,
        interactionControllerForDismissalType: UIAnimatedInteractionController.Type) {

        self.animationControllerForPresentationType = animationControllerForPresentationType
        self.animationControllerForDismissalType = animationControllerForDismissalType
        self.interactionControllerForPresentationType = interactionControllerForPresentationType
        self.interactionControllerForDismissalType = interactionControllerForDismissalType
    }

    init(
        animationControllerForPresentationType: UIAnimationController.Type,
        animationControllerForDismissalType: UIAnimationController.Type,
        presentationControllerType: UIInteractablePresentationController.Type,
        interactionControllerForDismissalType: UIAnimatedInteractionController.Type) {

        self.animationControllerForPresentationType = animationControllerForPresentationType
        self.animationControllerForDismissalType = animationControllerForDismissalType
        self.presentationControllerType = presentationControllerType
        self.interactionControllerForDismissalType = interactionControllerForDismissalType
    }

    init(
        animationControllerForPresentationType: UIAnimationController.Type,
        animationControllerForDismissalType: UIAnimationController.Type,
        presentationControllerType: UIInteractablePresentationController.Type,
        interactionControllerForPresentationType: UIAnimatedInteractionController.Type,
        interactionControllerForDismissalType: UIAnimatedInteractionController.Type) {

        self.animationControllerForPresentationType = animationControllerForPresentationType
        self.animationControllerForDismissalType = animationControllerForDismissalType
        self.presentationControllerType = presentationControllerType
        self.interactionControllerForPresentationType = interactionControllerForPresentationType
        self.interactionControllerForDismissalType = interactionControllerForDismissalType
    }

    init(childViewControllerReplacementAnimation: ChildViewControllerReplacementAnimation) {
        self.childViewControllerReplacementAnimation = childViewControllerReplacementAnimation
    }

}

// MARK: - UIViewControllerTransitioningDelegate

extension UISceneTransition: UIViewControllerTransitioningDelegate {

    public func animationController(
        forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return animationControllerForPresentation
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationControllerForDismissal
    }

    public func presentationController(
        forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        if let presentationController = self.presentationController {
            return presentationController
        }

        guard let presentationControllerType = presentationControllerType else { return nil }
        let presentationController = presentationControllerType.init(presentedViewController: presented, presenting: presenting)
        self.presentationController = presentationController
        return presentationController
    }

    public func interactionControllerForPresentation(
        using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        return interactionControllerForPresentation
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        if let presentationController = presentationController, presentationController.isInteracting {
            interactionControllerForDismissal?.animationController = animator
            presentationController.animatedInteractionController = interactionControllerForDismissal
            return interactionControllerForDismissal
        } else {
            return nil
        }
    }

}

// MARK: - UINavigationControllerDelegate

extension UISceneTransition: UINavigationControllerDelegate {

    public func navigationController(
        _ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push: return animationControllerForPresentation
        case .pop: return animationControllerForDismissal
        default: return nil
        }
    }

    public func navigationController(
        _ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {

        return interactionControllerForPresentation
    }

}

extension UISceneTransition: UITabBarControllerDelegate {

    public func tabBarController(
        _ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {

        return animationControllerForPresentation
    }

    public func tabBarController(
        _ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {

        return interactionControllerForPresentation
    }

}
