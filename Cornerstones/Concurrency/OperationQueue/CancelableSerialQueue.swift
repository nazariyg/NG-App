// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

/// Allows for cancelling enqueued operations on a serial queue. Already executing operations will continue.
public final class CancelableSerialQueue {

    public typealias WorkClosure = (_ isCancelled: (() -> Bool)) -> Void

    private let queue: OperationQueue

    public init(qos: DispatchQoS) {
        queue = OperationQueue()
        with(queue) {
            $0.maxConcurrentOperationCount = 1
            $0.qualityOfService = qos.operationQueueQoS
        }
    }

    public func async(_ work: @escaping WorkClosure) {
        synchronized(self) {
            let operation = CancelableSerialQueueOperation(work: work)
            queue.addOperation(operation)
        }
    }

    public func suspend() {
        synchronized(self) {
            queue.isSuspended = true
        }
    }

    public func resume() {
        synchronized(self) {
            queue.isSuspended = false
        }
    }

    public func cancelAll() {
        synchronized(self) {
            queue.cancelAllOperations()
        }
    }

}

private final class CancelableSerialQueueOperation: Operation {

    private let work: CancelableSerialQueue.WorkClosure

    init(work: @escaping CancelableSerialQueue.WorkClosure) {
        self.work = work
    }

    override func main() {
        guard !isCancelled else { return }
        let isCancelledClosure = { [weak self] () -> Bool in
            return self?.isCancelled ?? true
        }
        work(isCancelledClosure)
    }

}

private extension DispatchQoS {

    var operationQueueQoS: QualityOfService {
        switch self {
        case .background: return .background
        case .utility: return .utility
        case .default: return .default
        case .userInitiated: return .userInitiated
        case .userInteractive: return .userInteractive
        case .unspecified: return .default
        default: return .default
        }
    }

}
