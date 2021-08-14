// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Cornerstones
import RxSwift
import RxCocoa

public extension Single where Trait == SingleTrait {

    @inline(__always)
    func subscribeOnSuccess(_ onSuccessClosure: @escaping (Element) -> Void) -> Disposable {
        return subscribe(onSuccess: onSuccessClosure)
    }

    @inline(__always)
    func subscribeOnResult(_ onResultClosure: @escaping (Result<Element, CoreError>) -> Void) -> Disposable {
        return
            subscribe { event in
                switch event {
                case let .success(element):
                    let result: Result<Element, CoreError> = .success(element)
                    onResultClosure(result)
                case let .error(error):
                    let coreError = CoreError(error)
                    let result: Result<Element, CoreError> = .failure(coreError)
                    onResultClosure(result)
                }
            }
    }

    @inline(__always)
    func mapToVoid() -> Single<Void> {
        return map { _ in }
    }

    @inline(__always)
    func materializeToResultObservable() -> Observable<Result<Element, CoreError>> {
        return
            asObservable()
            .materialize()
            .map { event -> Result<Element, CoreError>? in
                switch event {
                case let .next(element):
                    return .success(element)
                case let .error(error):
                    let coreError = CoreError(error)
                    return .failure(coreError)
                default:
                    return nil
                }
            }
            .filterNil()
    }

    @inline(__always)
    func ignoringErrors() -> Observable<Element> {
        return
            materializeToResultObservable()
            .map { result -> Element? in try? result.get() }
            .filterNil()
    }

    @inline(__always)
    func ignoringEverything() -> Observable<Void> {
        return
            asObservable()
            .materialize()
            .mapToVoid()
    }

    @inline(__always)
    func delay(_ seconds: TimeInterval, scheduler: SchedulerType) -> PrimitiveSequence {
        let microseconds = Int(seconds*TimeInterval.microsecondsInSecond)
        return delay(.microseconds(microseconds), scheduler: scheduler)
    }

    @inline(__always)
    static func create(wrapIntoBackgroundTask: Bool, subscribe: @escaping (@escaping SingleObserver) -> Disposable) -> Single<Element> {
        if wrapIntoBackgroundTask {
            var backgroundTaskReference: BasicBackgroundTaskReference?
            return
                create(subscribe: subscribe)
                .do(
                    onSubscribe: {
                        backgroundTaskReference = BasicBackgroundTaskReference.begin()
                    },
                    onDispose: {
                        backgroundTaskReference?.end()
                    })

        } else {
            return create(subscribe: subscribe)

        }
    }

}
