// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Cornerstones
import RxSwift
import RxCocoa

public final class BehaviorRelayImmutabilityWrapper<Element>: ObservableType {

    private var relay: SettableBehaviorRelay<Element>?
    private var observable: Observable<Element>?
    private var currentElementFromObservable: Element?
    private var disposeBag: DisposeBag?

    @inline(__always)
    public init(_ relay: SettableBehaviorRelay<Element>) {
        self.relay = relay
    }

    /// The observable for wrapping *must* be derived from a behavior relay or the like.
    @inline(__always)
    public init(_ observable: Observable<Element>) {
        self.observable = observable.share(replay: 1)

        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag
        if let observable = self.observable {
            observable
                .subscribe(onNext: { [weak self] element in
                    guard let self = self else { return }
                    synchronized(self) {
                        self.currentElementFromObservable = element
                    }
                })
                .disposed(by: disposeBag)
        }
    }

    @inline(__always)
    public var value: Element {
        synchronized(self) {
            if let relay = relay {
                return relay.value
            } else if let currentElementFromObservable = currentElementFromObservable {
                return currentElementFromObservable
            } else {
                fatalError()
            }
        }
    }

    @inline(__always)
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        synchronized(self) {
            if let relay = relay {
                return relay.subscribe(observer)
            } else if let observable = observable {
                return observable.subscribe(observer)
            } else {
                fatalError()
            }
        }
    }

    @inline(__always)
    public func subscribeOnNext(_ onNextClosure: @escaping (Element) -> Void) -> Disposable {
        synchronized(self) {
            if let relay = relay {
                return relay.subscribeOnNext(onNextClosure)
            } else if let observable = observable {
                return observable.subscribe(onNext: onNextClosure)
            } else {
                fatalError()
            }
        }
    }

    @inline(__always)
    public func asObservable() -> Observable<Element> {
        synchronized(self) {
            if let relay = relay {
                return relay.asObservable()
            } else if let observable = observable {
                return observable
            } else {
               fatalError()
            }
        }
    }

}
