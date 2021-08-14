// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import RxSwift

class UIInteractablePresentationController: UIPresentationController {

    var interactiveDismissalEnabled: Bool {
        return true
    }

    private(set) var isInteracting = false
    weak var animatedInteractionController: UIAnimatedInteractionController?
    private let panGestureDisposable = AutoDisposable()

    required override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)

        guard
            interactiveDismissalEnabled,
            completed,
            let presentedView = presentedView
        else { return }

        panGestureDisposable <=
            presentedView.rx.panGesture()
            .subscribeOnNext { [weak self] gestureRecognizer in
                guard let self = self else { return }

                // Cancel touches while animating.
                if let animatedInteractionController = self.animatedInteractionController {
                    if !animatedInteractionController.canDoInteractiveTransition() {
                        gestureRecognizer.isEnabled = false
                        gestureRecognizer.isEnabled = true
                        return
                    }
                }

                switch gestureRecognizer.state {

                case .began:
                    self.isInteracting = true
                    self.presentingViewController.dismiss(animated: true, completion: nil)

                case .changed:
                    guard
                        let view = gestureRecognizer.view,
                        let animatedInteractionController = self.animatedInteractionController
                    else { break }

                    let translation = gestureRecognizer.translation(in: view)
                    animatedInteractionController.gestureRecognizerStateChanged(withTranslation: translation)

                case .ended, .cancelled:
                    self.isInteracting = false

                    guard let animatedInteractionController = self.animatedInteractionController else { break }
                    animatedInteractionController.gestureRecognizerEnded()

                default: break
                }
            }
    }

}
