// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import RxSwift
import RxCocoa

public extension ControlEvent {

    @inline(__always)
    func subscribeOnNext(_ onNextClosure: @escaping (Element) -> Void) -> Disposable {
        return self.asObservable().subscribeOnNext(onNextClosure)
    }

}
