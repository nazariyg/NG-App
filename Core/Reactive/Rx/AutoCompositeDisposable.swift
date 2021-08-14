// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import RxSwift
import RxCocoa

/// The `dispose` method disposed the internal `CompositeDisposable` but allows for new disposables to be added thereafter,
/// so unlike `CompositeDisposable` it is still reusable after calling the `dispose` method. Filled up with disposables using `+=` operator.
/// Disposes the internal `CompositeDisposable` on `deinit`.
public final class AutoCompositeDisposable {

    private var compositeDisposable = CompositeDisposable()

    @inline(__always)
    public init() {}

    @inline(__always)
    deinit {
        synchronized(self) {
            compositeDisposable.dispose()
        }
    }

    @inline(__always)
    public func dispose() {
        synchronized(self) {
            compositeDisposable.dispose()
            compositeDisposable = CompositeDisposable()
        }
    }

    @inline(__always)
    public static func += (autoCompositeDisposable: AutoCompositeDisposable, disposable: Disposable) {
        synchronized(self) {
            _ = autoCompositeDisposable.compositeDisposable.insert(disposable)
        }
    }

    @inline(__always)
    public static func +=<CollectionType: Collection> (
        autoCompositeDisposable: AutoCompositeDisposable, disposables: CollectionType) where CollectionType.Element == Disposable {

        synchronized(self) {
            for disposable in disposables {
                _ = autoCompositeDisposable.compositeDisposable.insert(disposable)
            }
        }
    }

    @inline(__always)
    public var count: Int {
        synchronized(self) {
            return compositeDisposable.count
        }
    }

}
