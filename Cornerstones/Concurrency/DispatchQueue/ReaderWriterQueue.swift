// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

/// Allows for fast state access synchronization using a concurrent queue, on which reading operations are isolated from writing operations,
/// and with performance optimizations for recursive calls. With this kind of queue, writing operations are synchronized among themselves while
/// reading operations can take place concurrently in a non-blocking manner as long as no writing operation is taking place at the same time.
public final class ReaderWriterQueue {

    private let queue: DispatchQueue
    private let queueSpecificKey = DispatchSpecificKey<String>()

    // MARK: - Lifecycle

    public convenience init(qos: DispatchQoS, labelSuffix: String = "", filePath: String = #file) {
        let label = DispatchQueue.uniqueQueueLabel(labelSuffix: labelSuffix, filePath: filePath)
        self.init(qos: qos, label: label)
    }

    public init(qos: DispatchQoS, label: String) {
        queue = DispatchQueue(label: label, qos: qos, attributes: .concurrent)
        queue.setSpecific(key: queueSpecificKey, value: label)
    }

    // MARK: - Reading and writing

    public func read<ReturnType>(_ work: ThrowingReturningClosure<ReturnType>) rethrows -> ReturnType {
        return try synchronized(self) {
            if isRecursive {
                return try work()
            } else {
                return try queue.sync(execute: work)
            }
        }
    }

    public func write(_ work: @escaping VoidClosure) {
        synchronized(self) {
            if isRecursive {
                work()
            } else {
                queue.async(flags: .barrier, execute: work)
            }
        }
    }

    // MARK: - Private

    private var isRecursive: Bool {
        return DispatchQueue.getSpecific(key: queueSpecificKey) == queue.label
    }

}
