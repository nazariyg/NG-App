// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import CoreLocation

public extension Collection {

    // `_` to avoid conflict with `isNotEmpty` declared in RxOptional.
    @inlinable
    var _isNotEmpty: Bool {
        return !isEmpty
    }

    @inlinable
    var lastIndex: Index {
        return index(endIndex, offsetBy: -1)
    }

    @inlinable
    subscript(safe index: Index) -> Element? {
        return startIndex <= index && index < endIndex ? self[index] : nil
    }

}

public extension MutableCollection {

    @inlinable
    subscript(safe index: Index) -> Element? {
        get {
            return startIndex <= index && index < endIndex ? self[index] : nil
        }

        set(element) {
            if let element = element {
                if startIndex <= index && index < endIndex {
                    self[index] = element
                }
            }
        }
    }

}
