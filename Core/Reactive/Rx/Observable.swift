// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import RxSwift
import RxCocoa

public extension Observable {

    @inline(__always)
    func subscribeOnNext(_ onNextClosure: @escaping (Element) -> Void) -> Disposable {
        return subscribe(onNext: onNextClosure)
    }

    @inline(__always)
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }

    @inline(__always)
    func bindNext<Observer: ObserverType>(to observer: Observer) -> Disposable where Observer.Element == Element {
        return subscribe(onNext: { element in
            observer.onNext(element)
        })
    }

    @inline(__always)
    func subscribeOnResult(_ onResultClosure: @escaping (Result<Element, CoreError>) -> Void) -> Disposable {
        return
            subscribe { (event: Event<Element>) -> Void in
                switch event {
                case let .next(element):
                    let result: Result<Element, CoreError> = .success(element)
                    onResultClosure(result)
                case let .error(error):
                    let coreError = CoreError(error)
                    let result: Result<Element, CoreError> = .failure(coreError)
                    onResultClosure(result)
                default:
                    break
                }
            }
    }

    @inline(__always)
    func materializeToResult() -> Observable<Result<Element, CoreError>> {
        return
            materialize()
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
    func ignoreErrors() -> Observable {
        return
            materializeToResult()
            .map { result -> Element? in try? result.get() }
            .filterNil()
    }

    @inline(__always)
    func delay(_ seconds: TimeInterval, scheduler: SchedulerType) -> Observable {
        let microseconds = Int(seconds*TimeInterval.microsecondsInSecond)
        return delay(.microseconds(microseconds), scheduler: scheduler)
    }

    @inline(__always)
    func debounce(_ seconds: TimeInterval, scheduler: SchedulerType) -> Observable {
        let microseconds = Int(seconds*TimeInterval.microsecondsInSecond)
        return debounce(.microseconds(microseconds), scheduler: scheduler)
    }

    @inline(__always)
    func throttle(_ seconds: TimeInterval, scheduler: SchedulerType) -> Observable {
        let microseconds = Int(seconds*TimeInterval.microsecondsInSecond)
        return throttle(.microseconds(microseconds), scheduler: scheduler)
    }

    @inline(__always)
    func skip(_ seconds: TimeInterval, scheduler: SchedulerType) -> Observable {
        let microseconds = Int(seconds*TimeInterval.microsecondsInSecond)
        return skip(.microseconds(microseconds), scheduler: scheduler)
    }

    /// Unlike `withLatestFrom` that requires the second observable to emit before the first observable does, `combineWithLatestFrom` always waits
    /// until the second observable emits an element to emit its initial element and then behaves like the regular `withLatestFrom`.
    @inline(__always)
    func combineWithLatestFrom<Source: ObservableType>(_ second: Source) -> Observable<Source.Element> {
        let firstElement: Observable<Source.Element> =
            Observable<Any>.combineLatest(
                self,
                second
            )
            .map { $0.1 }
            .take(1)

        return
            Observable<Source.Element>.merge(
                firstElement,
                self.skipUntil(firstElement).withLatestFrom(second))
    }

    @inline(__always)
    func combineWithLatestFromAsPair<Source: ObservableType>(_ second: Source) -> Observable<(Element, Source.Element)> {
        let firstElement: Observable<(Element, Source.Element)> =
            Observable<Any>.combineLatest(
                self,
                second
            )
            .take(1)

        return
            Observable<(Element, Source.Element)>.merge(
                firstElement,
                self.skipUntil(firstElement).withLatestFrom(second, resultSelector: { ($0, $1) }))
    }

}

public extension Observable where Element: RxAbstractInteger {

    @inline(__always)
    static func interval(_ seconds: TimeInterval, scheduler: SchedulerType) -> Observable {
        let microseconds = Int(seconds*TimeInterval.microsecondsInSecond)
        return interval(.microseconds(microseconds), scheduler: scheduler)
    }

}

public extension Observable where Element: Collection, Element.Element: Hashable {

    /// For sets only. Unlike the native `==` operator that may compare set elements in a random order and more times than there are elements in each set,
    /// compares sets by first sorting their elements based on `hashValue` and then comparing elements one by one as many times as minimally necessary.
    @inline(__always)
    func distinctUntilChangedComparingInHashOrder() -> O<Element> {
        return distinctUntilChanged { set1, set2 in
            guard set1.count == set2.count else {
                // Different sizes.
                return false
            }
            guard set1.count != 0 else {
                // Both are empty.
                return true
            }

            var array1 = Array(set1)
            var array2 = Array(set2)
            array1.sort(by: { $0.hashValue < $1.hashValue })
            array2.sort(by: { $0.hashValue < $1.hashValue })
            return array1 == array2
        }
    }

}
