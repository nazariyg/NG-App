// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import RxSwift
import RxCocoa

public extension ObserverType {

    @inline(__always)
    func send(_ element: Element) {
        onNext(element)
    }

    @inline(__always)
    func sendError(_ error: Error) {
        onError(error)
    }

    @inline(__always)
    func sendCompleted() {
        onCompleted()
    }

}
