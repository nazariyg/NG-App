// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import RxSwift

public protocol BiBindable {
    associatedtype Element
    func biBind(to property: SettableBehaviorRelay<Element>) -> Disposable
}
