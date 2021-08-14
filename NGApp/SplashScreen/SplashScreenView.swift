// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import RxSwift
import UICore
import Cartography

// MARK: - Protocol

protocol SplashScreenViewProtocol {
    func wireIn(viper: SplashScreenScene.MainSchedulerWiring)
    var events: O<SplashScreenView.Event> { get }
}

// MARK: - Implementation

final class SplashScreenView: UIViewControllerBase, SplashScreenViewProtocol, EventEmitter {

    enum Event { case _unused }

    private var launchScreenViewControllerView: UIView!
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func initialize() {
        fill()
        layout()
    }

    // MARK: - Content

    private func fill() {
        guard let launchScreenViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() else {
            assertionFailure()
            return
        }
        addChild(launchScreenViewController)
        launchScreenViewControllerView = launchScreenViewController.view
        contentView.addSubview(launchScreenViewControllerView)
        launchScreenViewController.didMove(toParent: self)
    }

    private func layout() {
        constrain(launchScreenViewControllerView, contentView) { view, superview in
            view.edges == superview.edges
        }
    }

    // MARK: - Requests

    func wireIn(viper: SplashScreenScene.MainSchedulerWiring) {}

}
