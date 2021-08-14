// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

public extension UINavigationController {

    func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping VoidClosure) {
        pushViewController(viewController, animated: animated)

        guard
            animated,
            let coordinator = transitionCoordinator else {

            DispatchQueue.main.async { completion() }
            return
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }

    @discardableResult
    func popViewController(animated: Bool, completion: @escaping VoidClosure) -> UIViewController? {
        let poppedViewController = popViewController(animated: animated)

        guard
            animated,
            let coordinator = transitionCoordinator else {

            DispatchQueue.main.async { completion() }
            return poppedViewController
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }

        return poppedViewController
    }

    @discardableResult
    func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping VoidClosure) -> [UIViewController]? {
        let poppedViewControllers = popToViewController(viewController, animated: animated)

        guard
            animated,
            let coordinator = transitionCoordinator else {

            DispatchQueue.main.async { completion() }
            return poppedViewControllers
        }

        coordinator.animate(alongsideTransition: nil) { _ in completion() }

        return poppedViewControllers
    }

}
