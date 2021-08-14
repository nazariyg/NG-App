// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import RxSwift

public extension SerialDispatchQueueScheduler {

    @inline(__always)
    func schedule(_ work: @escaping VoidClosure) {
        var disposable: Disposable?
        disposable =
            schedule(()) {
                work()
                disposable?.dispose()
                return Disposables.create()
            }
    }

}
