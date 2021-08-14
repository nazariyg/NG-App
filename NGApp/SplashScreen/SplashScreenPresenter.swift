// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift
import UICore

// MARK: - Protocol

protocol SplashScreenPresenterProtocol {
    init(workerQueueScheduler: SerialDispatchQueueScheduler)
    func wireIn(viper: SplashScreenScene.WorkerQueueSchedulerWiring)
    var events: O<SplashScreenPresenter.Event> { get }
    var requests: O<SplashScreenPresenter.Request> { get }
}

// MARK: - Implementation

final class SplashScreenPresenter: SplashScreenPresenterProtocol, EventEmitter, RequestEmitter {

    enum Event { case _unused }

    enum Request { case _unused }

    private let workerQueueScheduler: SerialDispatchQueueScheduler
    private let disposeBag = DisposeBag()

    init(workerQueueScheduler: SerialDispatchQueueScheduler) {
        self.workerQueueScheduler = workerQueueScheduler
    }

    func wireIn(viper: SplashScreenScene.WorkerQueueSchedulerWiring) {}

}
