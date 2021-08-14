// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import RxSwift
import RxCocoa

/// Auto-disposes on deinit and when reassigning to another disposable using `<=`. Disposes the internal `Disposable` on `deinit`.
public final class AutoDisposable {

    private var disposable: Disposable?

    @inline(__always)
    public init() {}

    @inline(__always)
    deinit {
        dispose()
    }

    @inline(__always)
    public func dispose() {
        synchronized(self) {
            disposable?.dispose()
            disposable = nil
        }
    }

    @inline(__always)
    public var isDisposed: Bool {
        synchronized(self) {
            return disposable == nil
        }
    }

    @inline(__always)
    public static func <= (autoDisposable: AutoDisposable, disposable: Disposable) {
        synchronized(self) {
            autoDisposable.dispose()
            autoDisposable.disposable = disposable
        }
    }

}
