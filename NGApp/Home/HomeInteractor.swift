// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift
import UICore

// MARK: - Protocol

protocol HomeInteractorProtocol {
    init(workerQueueScheduler: SerialDispatchQueueScheduler)
    func go()
    func wireIn(viper: HomeScene.WorkerQueueSchedulerWiring)
    var events: O<HomeInteractor.Event> { get }
    var requests: O<HomeInteractor.Request> { get }
}

// MARK: - Implementation

final class HomeInteractor: HomeInteractorProtocol, EventEmitter, RequestEmitter {

    enum Event { case _unused }

    enum Request { case _unused }

    private let workerQueueScheduler: SerialDispatchQueueScheduler
    private let disposeBag = DisposeBag()

    init(workerQueueScheduler: SerialDispatchQueueScheduler) {
        self.workerQueueScheduler = workerQueueScheduler
    }

    func go() {}

    func wireIn(viper: HomeScene.WorkerQueueSchedulerWiring) {}

}
