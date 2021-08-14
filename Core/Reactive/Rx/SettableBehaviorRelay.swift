// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Cornerstones
import RxSwift
import RxCocoa
import RxBiBinding

public final class SettableBehaviorRelay<Element>: ObservableType {

    private let relay: BehaviorRelay<Element>

    @inline(__always)
    public init(_ element: Element) {
        relay = BehaviorRelay(value: element)
    }

    @inline(__always)
    public var value: Element {
        get {
            return relay.value
        }

        set(element) {
            relay.accept(element)
        }
    }

    @inline(__always)
    public func subscribeOnNext(_ onNextClosure: @escaping (Element) -> Void) -> Disposable {
        return relay.subscribe(onNext: onNextClosure)
    }

    @inline(__always)
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        return relay.subscribe(observer)
    }

    @inline(__always)
    public func asObservable() -> Observable<Element> {
        return relay.asObservable()
    }

    @inline(__always)
    public func bidirectionalBind(to controlProperty: ControlProperty<Element>) -> Disposable {
        return controlProperty <-> relay
    }

    @inline(__always)
    public func bidirectionalBind(to otherRelay: BehaviorRelay<Element>) -> Disposable {
        return relay <-> otherRelay
    }

}

// For the `bind(to:)` operator to be used on `SettableBehaviorRelay`.
extension SettableBehaviorRelay: ObserverType {

    @inline(__always)
    public func on(_ event: Event<Element>) {
        switch event {
        case let .next(element):
            value = element
        default:
            // If you are getting here because of e.g. `completed` events, consider using `bindNext(to:)` instead of `bind(to:)`.
            assertionFailure()
        }
    }

}
