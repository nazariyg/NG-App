// Copyright © ___YEAR___ Nazariy Gorpynyuk.
// All rights reserved.

import UIKit
import Cornerstones
import Core
import RxSwift
import UICore
import Cartography

// MARK: - Protocol

protocol ___VARIABLE_view___Protocol {
    func wireIn(viper: ___VARIABLE_scene___.MainSchedulerWiring)
    var events: O<___VARIABLE_view___.Event> { get }
}

// MARK: - Implementation

final class ___VARIABLE_view___: UIViewControllerBase, ___VARIABLE_view___Protocol, EventEmitter {

    enum Event { case _unused }

    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    override func initialize() {
        //

        fill()
        layout()
    }

    // MARK: - Content

    private func fill() {
        //
    }

    private func layout() {
        //
    }

    // MARK: - Requests

    func wireIn(viper: ___VARIABLE_scene___.MainSchedulerWiring) {}

}
