// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import RxSwift
import RxCocoa

public extension PublishRelay {

    @inline(__always)
    func send(_ element: Element) {
        accept(element)
    }

    @inline(__always)
    func subscribeOnNext(_ onNextClosure: @escaping (Element) -> Void) -> Disposable {
        return subscribe(onNext: onNextClosure)
    }

    @inline(__always)
    func delay(_ seconds: TimeInterval, scheduler: SchedulerType) -> Observable<Element> {
        let microseconds = Int(seconds*TimeInterval.microsecondsInSecond)
        return delay(.microseconds(microseconds), scheduler: scheduler)
    }

    @inline(__always)
    func debounce(_ seconds: TimeInterval, scheduler: SchedulerType) -> Observable<Element> {
        let microseconds = Int(seconds*TimeInterval.microsecondsInSecond)
        return debounce(.microseconds(microseconds), scheduler: scheduler)
    }

    @inline(__always)
    func throttle(_ seconds: TimeInterval, scheduler: SchedulerType) -> Observable<Element> {
        let microseconds = Int(seconds*TimeInterval.microsecondsInSecond)
        return throttle(.microseconds(microseconds), scheduler: scheduler)
    }

}
