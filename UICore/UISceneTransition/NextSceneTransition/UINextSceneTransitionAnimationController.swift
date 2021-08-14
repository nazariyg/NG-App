// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Cornerstones
import UIKit

final class UINextSceneTransitionAnimationController: NSObject, UIAnimationController {

    private static let animationDuration: TimeInterval = 1
    private static let zoomOutRatio: CGFloat = 0.8
    private static let offsetRatio: CGFloat = 0.33
    private static let minAlpha: CGFloat = 0.25
    private static let animationDampingRatio: CGFloat = 0.8

    private let isReversed: Bool
    private var animator: UIViewImplicitlyAnimating?

    init(isReversed: Bool) {
        self.isReversed = isReversed
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Self.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animator = self.animator {
            return animator
        }

        let context = transitionContext.unpack()

        if !isReversed {
            context.containerView.insertSubview(context.toView, aboveSubview: context.fromView)
        } else {
            context.containerView.insertSubview(context.toView, belowSubview: context.fromView)
        }

        let toViewStartFrame = context.fromViewStartFrame.offsetBy(dx: context.fromViewStartFrame.width, dy: 0)
        let fromViewEndFrame = context.fromViewStartFrame.offsetBy(dx: -context.fromViewStartFrame.width*Self.offsetRatio, dy: 0)
        let fromViewEndTransform = CGAffineTransform(scaleX: Self.zoomOutRatio, y: Self.zoomOutRatio)
        let fromViewEndAlpha = Self.minAlpha

        if !isReversed {
            context.toView.frame = toViewStartFrame
        } else {
            context.toView.transform = fromViewEndTransform
            context.toView.frame = fromViewEndFrame
            context.toView.bounds = CGRect(origin: .zero, size: fromViewEndFrame.size)
            context.toView.alpha = fromViewEndAlpha
        }

        let animator =
            UIViewPropertyAnimator(duration: Self.animationDuration, dampingRatio: Self.animationDampingRatio,
                animations: { [isReversed] in
                    if !isReversed {
                        context.fromView.transform = fromViewEndTransform
                        context.fromView.frame = fromViewEndFrame
                        context.fromView.bounds = fromViewEndFrame.size.rect
                        context.fromView.alpha = fromViewEndAlpha

                        context.toView.frame = context.fromViewStartFrame
                    } else {
                        context.fromView.frame = toViewStartFrame

                        context.toView.transform = .identity
                        context.toView.frame = context.fromViewStartFrame
                        context.toView.bounds = context.fromViewStartFrame.size.rect
                        context.toView.alpha = 1
                    }
                })

        animator.addCompletion { _ in
            context.fromView.transform = .identity
            context.fromView.alpha = 1

            context.toView.transform = .identity
            context.toView.alpha = 1

            transitionContext.completeTransition(true)
        }

        self.animator = animator
        return animator
    }

    func animationEnded(_ transitionCompleted: Bool) {
        animator = nil
    }

}
