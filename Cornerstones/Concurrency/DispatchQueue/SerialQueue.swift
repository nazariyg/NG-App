// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

/// Allows for non-blocking recursive synchronous operations on a serial queue.
public final class SerialQueue {

    public let queue: DispatchQueue
    public let label: String
    public private(set) var suspendCount = 0

    private let queueSpecificKey = DispatchSpecificKey<String>()

    // MARK: - Lifecycle

    public convenience init(qos: DispatchQoS, labelSuffix: String = "", filePath: String = #file) {
        let label = DispatchQueue.uniqueQueueLabel(labelSuffix: labelSuffix, filePath: filePath)
        self.init(qos: qos, label: label)
    }

    public init(qos: DispatchQoS, label: String) {
        queue = DispatchQueue(label: label, qos: qos)
        queue.setSpecific(key: queueSpecificKey, value: label)

        self.label = label
    }

    deinit {
        if suspendCount > 0 {
            // Avoid crashing when deallocating a suspended `DispatchQueue`.
            resume()
        }
    }

    // MARK: - Operations

    @discardableResult
    public func sync<ReturnType>(_ work: ThrowingReturningClosure<ReturnType>) rethrows -> ReturnType {
        return try synchronized(self) {
            if isRecursive {
                return try work()
            } else {
                return try queue.sync(execute: work)
            }
        }
    }

    public func async(_ work: @escaping VoidClosure) {
        synchronized(self) {
            queue.async(execute: work)
        }
    }

    public func asyncIfNeeded(_ work: @escaping VoidClosure) {
        synchronized(self) {
            if isRecursive {
                work()
            } else {
                queue.async(execute: work)
            }
        }
    }

    public func suspend() {
        synchronized(self) {
            suspendCount += 1
            queue.suspend()
        }
    }

    public func resume() {
        synchronized(self) {
            suspendCount -= 1
            assert(suspendCount >= 0, "Excessive resume attempts")
            queue.resume()
        }
    }

    // MARK: - Private

    private var isRecursive: Bool {
        return DispatchQueue.getSpecific(key: queueSpecificKey) == queue.label
    }

}
