// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

protocol UIAnimatedInteractionController: UIViewControllerInteractiveTransitioning {

    init()

    var animationController: UIViewControllerAnimatedTransitioning? { get set }

    func canDoInteractiveTransition() -> Bool
    func gestureRecognizerStateChanged(withTranslation translation: CGPoint)
    func gestureRecognizerEnded()

}
