// Copyright © ___YEAR___ Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift
import UICore

// MARK: - Protocol

protocol ___VARIABLE_interactor___Protocol {
    init(workerQueueScheduler: SerialDispatchQueueScheduler)
    func go()
    func wireIn(viper: ___VARIABLE_scene___.WorkerQueueSchedulerWiring)
    var events: O<___VARIABLE_interactor___.Event> { get }
    var requests: O<___VARIABLE_interactor___.Request> { get }
}

// MARK: - Implementation

final class ___VARIABLE_interactor___: ___VARIABLE_interactor___Protocol, EventEmitter, RequestEmitter {

    enum Event { case _unused }

    enum Request { case _unused }

    private let workerQueueScheduler: SerialDispatchQueueScheduler
    private let disposeBag = DisposeBag()

    init(workerQueueScheduler: SerialDispatchQueueScheduler) {
        self.workerQueueScheduler = workerQueueScheduler
    }

    func go() {}

    func wireIn(viper: ___VARIABLE_scene___.WorkerQueueSchedulerWiring) {}

}
