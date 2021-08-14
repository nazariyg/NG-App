// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

/// Replacement for Objective-C's `@synchronized`, with added support for return values.
public func synchronized<ReturnType>(_ lockToken: AnyObject, closure: ThrowingReturningClosure<ReturnType>) rethrows -> ReturnType {
    objc_sync_enter(lockToken)
    defer { objc_sync_exit(lockToken) }
    return try closure()
}

/// Replacement for Objective-C's `@synchronized`, with added support for return values.
public func synchronized<ReturnType>(_ lockToken1: AnyObject, _ lockToken2: AnyObject, closure: ThrowingReturningClosure<ReturnType>) rethrows -> ReturnType {
    objc_sync_enter(lockToken1)
    objc_sync_enter(lockToken2)
    defer {
        objc_sync_exit(lockToken1)
        objc_sync_exit(lockToken2)
    }
    return try closure()
}
