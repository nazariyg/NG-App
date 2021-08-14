// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import RxSwift
import UICore
import Cartography

// MARK: - Protocol

protocol HomeViewProtocol {
    func wireIn(viper: HomeScene.MainSchedulerWiring)
    var events: O<HomeView.Event> { get }
}

// MARK: - Implementation

final class HomeView: UIViewControllerBase, HomeViewProtocol, EventEmitter {

    private static let horizontalMargin = s(32)
    private static let verticalMargin = s(32)

    enum Event { case _unused }

    private var label: UIStyledLabel!
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func initialize() {
        fill()
        layout()
    }

    // MARK: - Content

    private func fill() {
        label = .init()
        withOptional(label) {
            $0.text = "Please see my code!"
            $0.font = .mainBold(56)
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.5

            contentView.addSubview($0)
        }
    }

    private func layout() {
        constrain(label, contentView) { view, superview in
            view.top == superview.safeAreaLayoutGuide.top + Self.verticalMargin
            view.leading == superview.leading + Self.horizontalMargin
            view.trailing == superview.trailing - Self.horizontalMargin
            view.bottom == superview.safeAreaLayoutGuide.bottom - Self.verticalMargin
        }
    }

    // MARK: - Requests

    func wireIn(viper: HomeScene.MainSchedulerWiring) {}

}
