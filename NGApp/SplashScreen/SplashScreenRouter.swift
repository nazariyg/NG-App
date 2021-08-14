// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift
import UICore

// MARK: - Protocol

protocol SplashScreenRouterProtocol {
    func wireIn(viper: SplashScreenScene.WorkerQueueSchedulerWiring)
}

// MARK: - Implementation

final class SplashScreenRouter: SplashScreenRouterProtocol {

    private let disposeBag = DisposeBag()

    func wireIn(viper: SplashScreenScene.WorkerQueueSchedulerWiring) {
        viper.interactor.events
            .subscribeOnNext { event in
                switch event {

                case .completed:
                    UIGlobalSceneRouter.shared.takeover(afterSceneType: SplashScreenScene.self)

                }
            }
            .disposed(by: disposeBag)
    }

}
