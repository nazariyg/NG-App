// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension Set {

    /// Removes all the elements that satisfy the given predicate. Returns `true` if any elements were removed, `false` otherwise.
    @discardableResult
    @inlinable
    mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows -> Bool {
        let oldCount = count
        var array = Array(self)
        try array.removeAll(where: shouldBeRemoved)
        self = Self(array)
        return count != oldCount
    }

}
