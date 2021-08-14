// Copyright © ___YEAR___ Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import Core
import RxSwift
import UICore

public final class ___VARIABLE_scene___: UICore.UIScene {

    public struct Parameters {}

    final class Components {
        var interactor: ___VARIABLE_interactor___Protocol!
        var presenter: ___VARIABLE_presenter___Protocol!
        var view: ___VARIABLE_view___Protocol!
        var router: ___VARIABLE_router___Protocol!
    }

    public private(set) lazy var sceneIsInitialized: O<Bool> = _sceneIsInitialized.asObservable()
    private let _sceneIsInitialized = V<Bool>(false)
    private let disposeBag = DisposeBag()

    private let components = Components()

    public init(parameters: Parameters?) {
        DispatchQueue.syncSafeOnMain {
            components.view =
                InstanceService.shared.instance(for: ___VARIABLE_view___Protocol.self, defaultInstance: ___VARIABLE_view___())
            viewController.loadViewIfNeeded()

            let workerQueueLabel = DispatchQueue.uniqueQueueLabel()
            let workerQueueScheduler = SerialDispatchQueueScheduler(qos: Config.shared.general.viperWorkerQueueQoS, internalSerialQueueName: workerQueueLabel)

            let goProperty: P<Bool> = P(
                O.combineLatest(
                    _sceneIsInitialized.filter({ $0 }),
                    viewController.rx.viewDidLayoutSubviews
                )
                .observeOn(MainScheduler.asyncInstance)
                .map { _ in true }
                .startWith(false))
            let goObservable: O<Void> = goProperty.filter({ $0 }).mapToVoid().take(1)
            let workerQueueSchedulerWiring = WorkerQueueSchedulerWiring(go: goObservable, components: components, on: workerQueueScheduler)
            let mainSchedulerWiring = MainSchedulerWiring(go: goObservable, components: components)

            workerQueueScheduler.schedule { [components, _sceneIsInitialized, disposeBag] in
                components.interactor =
                    InstanceService.shared.instance(
                        for: ___VARIABLE_interactor___Protocol.self,
                        defaultInstance: ___VARIABLE_interactor___(parameters: parameters, workerQueueScheduler: workerQueueScheduler))
                components.presenter =
                    InstanceService.shared.instance(
                        for: ___VARIABLE_presenter___Protocol.self,
                        defaultInstance: ___VARIABLE_presenter___(workerQueueScheduler: workerQueueScheduler))
                components.router =
                    InstanceService.shared.instance(for: ___VARIABLE_router___Protocol.self, defaultInstance: ___VARIABLE_router___())

                components.interactor.wireIn(viper: workerQueueSchedulerWiring)
                components.presenter.wireIn(viper: workerQueueSchedulerWiring)
                components.router.wireIn(viper: workerQueueSchedulerWiring)

                DispatchQueue.main.async {
                    components.view.wireIn(viper: mainSchedulerWiring)
                    _sceneIsInitialized.value = true

                    goProperty
                        .observeOn(workerQueueScheduler)
                        .filter { $0 }
                        .take(1)
                        .subscribeOnNext { _ in components.interactor.go() }
                        .disposed(by: disposeBag)
                }
            }
        }
    }

    public var viewController: UIViewController {
        return components.view as! UIViewController
    }

    // Wired in by the interactor, the presenter, and the router.
    struct WorkerQueueSchedulerWiring {

        struct ViewEvents {
            let events: O<___VARIABLE_view___.Event>
        }

        let interactorGo: O<Void>
        let viewOnMainScheduler: O<___VARIABLE_view___Protocol>
        private(set) weak var components: Components!

        private let go: O<Void>
        private let workerQueueScheduler: SerialDispatchQueueScheduler

        init(go: O<Void>, components: Components, on workerQueueScheduler: SerialDispatchQueueScheduler) {
            interactorGo =
                go
                .observeOn(workerQueueScheduler)

            viewOnMainScheduler =
                go
                .observeOn(MainScheduler.instance)
                .map { components.view }

            self.go = go
            self.components = components
            self.workerQueueScheduler = workerQueueScheduler
        }

        var interactor: (events: O<___VARIABLE_interactor___.Event>, requests: O<___VARIABLE_interactor___.Request>) {
            let events =
                O.combineLatest(go, components.interactor.events)
                .map { $1 }
                .observeOn(workerQueueScheduler)

            let requests =
                O.combineLatest(go, components.interactor.requests)
                .map { $1 }
                .observeOn(workerQueueScheduler)

            return (events, requests)
        }

        var presenter: (events: O<___VARIABLE_presenter___.Event>, requests: O<___VARIABLE_presenter___.Request>) {
            let events =
                O.combineLatest(go, components.presenter.events)
                .map { $1 }
                .observeOn(workerQueueScheduler)

            let requests =
                O.combineLatest(go, components.presenter.requests)
                .map { $1 }
                .observeOn(workerQueueScheduler)

            return (events, requests)
        }

        var view: ViewEvents {
            let events =
                O.combineLatest(go, components.view.events)
                .map { $1 }
                .observeOn(workerQueueScheduler)

            return .init(events: events)
        }

        func biBind<BiBindableType: BiBindable>(
            _ variable: V<BiBindableType.Element>, toView viewPropertyKeyPath: KeyPath<___VARIABLE_view___Protocol, BiBindableType>, disposeBag: DisposeBag) {

            viewOnMainScheduler
                .subscribeOnNext { view in
                    view[keyPath: viewPropertyKeyPath].biBind(to: variable).disposed(by: disposeBag)
                }
                .disposed(by: disposeBag)
        }

    }

    // Wired in by the view.
    struct MainSchedulerWiring {
        private(set) weak var components: Components!

        private let go: O<Void>

        init(go: O<Void>, components: Components) {
            self.go = go
            self.components = components
        }

        var interactor: (events: O<___VARIABLE_interactor___.Event>, requests: O<___VARIABLE_interactor___.Request>) {
            let events =
                O.combineLatest(go, components.interactor.events)
                .map { $1 }
                .observeOn(MainScheduler.instance)

            let requests =
                O.combineLatest(go, components.interactor.requests)
                .map { $1 }
                .observeOn(MainScheduler.instance)

            return (events, requests)
        }

        var presenter: (events: O<___VARIABLE_presenter___.Event>, requests: O<___VARIABLE_presenter___.Request>) {
            let events =
                O.combineLatest(go, components.presenter.events)
                .map { $1 }
                .observeOn(MainScheduler.instance)

            let requests =
                O.combineLatest(go, components.presenter.requests)
                .map { $1 }
                .observeOn(MainScheduler.instance)

            return (events, requests)
        }

    }

}
