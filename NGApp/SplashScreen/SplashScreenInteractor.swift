// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift
import UICore

// MARK: - Protocol

protocol SplashScreenInteractorProtocol {
    init(workerQueueScheduler: SerialDispatchQueueScheduler)
    func go()
    func wireIn(viper: SplashScreenScene.WorkerQueueSchedulerWiring)
    var events: O<SplashScreenInteractor.Event> { get }
    var requests: O<SplashScreenInteractor.Request> { get }
}

// MARK: - Implementation

final class SplashScreenInteractor: SplashScreenInteractorProtocol, EventEmitter, RequestEmitter {

    enum Event {
        case completed
    }

    enum Request { case _unused }

    private let workerQueueScheduler: SerialDispatchQueueScheduler
    private let disposeBag = DisposeBag()

    init(workerQueueScheduler: SerialDispatchQueueScheduler) {
        self.workerQueueScheduler = workerQueueScheduler
    }

    func go() {}

    func wireIn(viper: SplashScreenScene.WorkerQueueSchedulerWiring) {
        let splashScreenDisplayMinTime = Config.shared.general.splashScreenDisplayMinTime

        let splashScreenWaitingCompletion: O<Void> =
            viper.interactorGo
            .delay(splashScreenDisplayMinTime, scheduler: MainScheduler.instance)

        O.combineLatest(
                viper.interactorGo,
                splashScreenWaitingCompletion
            )
            .observeOn(workerQueueScheduler)
            .take(1)
            .map { _ -> Event in .completed }
            .bind(to: eventEmitter)
            .disposed(by: disposeBag)
    }

}
