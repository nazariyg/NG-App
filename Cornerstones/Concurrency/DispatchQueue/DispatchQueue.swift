// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension DispatchQueue {

    // MARK: - Shortcuts for global prioritized concurrent queues

    static var userInteractive: DispatchQueue {
        return DispatchQueue.global(qos: .userInteractive)
    }

    static var userInitiated: DispatchQueue {
        return DispatchQueue.global(qos: .userInitiated)
    }

    static var `default`: DispatchQueue {
        return DispatchQueue.global(qos: .default)
    }

    static var utility: DispatchQueue {
        return DispatchQueue.global(qos: .utility)
    }

    static var background: DispatchQueue {
        return DispatchQueue.global(qos: .background)
    }

    // MARK: - Smarter closure execution by queue instances

    /// Synchronously runs a closure on the selected queue, simply executing the closure in-place if the selected queue and the current queue
    /// are both the main queue thus avoiding a deadlock.
    @discardableResult
    static func syncSafeOnMain<ReturnType>(_ work: ThrowingReturningClosure<ReturnType>) rethrows -> ReturnType {
        if Thread.isMainThread {
            // Already on the main queue.
            return try work()
        } else {
            return try main.sync {
                return try work()
            }
        }
    }

    /// Asynchronously runs a void-returning closure, if non-nil, on the selected queue after the specified delay, using `autoreleasepool` if
    /// the selected queue is not the main queue.
    func asyncAfter(_ delay: TimeInterval, _ work: VoidClosure?) {
        guard let work = work else { return }
        asyncAfter(deadline: .now() + delay, execute: {
            if Thread.isMainThread {
                work()
            } else {
                // Improve memory management with `autoreleasepool`.
                autoreleasepool {
                    work()
                }
            }
        })
    }

    // MARK: - Queue identification

    /// Returns the label of the queue the caller is currently running on.
    static var currentQueueLabel: String {
        let label = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!
        return label
    }

}
