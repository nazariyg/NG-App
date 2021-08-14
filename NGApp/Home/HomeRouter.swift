// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift
import UICore

// MARK: - Protocol

protocol HomeRouterProtocol {
    func wireIn(viper: HomeScene.WorkerQueueSchedulerWiring)
}

// MARK: - Implementation

final class HomeRouter: HomeRouterProtocol {

    private let disposeBag = DisposeBag()

    func wireIn(viper: HomeScene.WorkerQueueSchedulerWiring) {}

}
