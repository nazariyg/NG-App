// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import RxSwift
import RxCocoa
import RxBiBinding

public extension ControlProperty {

    @inline(__always)
    func bidirectionalBind(to otherControlProperty: ControlProperty<Element>) -> Disposable {
        return self <-> otherControlProperty
    }

}
