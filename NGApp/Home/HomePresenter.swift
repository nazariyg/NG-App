// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift
import UICore

// MARK: - Protocol

protocol HomePresenterProtocol {
    init(workerQueueScheduler: SerialDispatchQueueScheduler)
    func wireIn(viper: HomeScene.WorkerQueueSchedulerWiring)
    var events: O<HomePresenter.Event> { get }
    var requests: O<HomePresenter.Request> { get }
}

// MARK: - Implementation

final class HomePresenter: HomePresenterProtocol, EventEmitter, RequestEmitter {

    enum Event { case _unused }

    enum Request { case _unused }

    private let workerQueueScheduler: SerialDispatchQueueScheduler
    private let disposeBag = DisposeBag()

    init(workerQueueScheduler: SerialDispatchQueueScheduler) {
        self.workerQueueScheduler = workerQueueScheduler
    }

    func wireIn(viper: HomeScene.WorkerQueueSchedulerWiring) {}

}
