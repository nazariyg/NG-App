// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import RxSwift
import RxCocoa

public extension SerialQueue {

    @inline(__always)
    func queueScheduler() -> SerialDispatchQueueScheduler {
        return SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: label)
    }

}
