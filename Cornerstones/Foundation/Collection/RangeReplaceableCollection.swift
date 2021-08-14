// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension RangeReplaceableCollection {

    @inlinable
    func appending(_ newElement: Element) -> Self {
        var collection = Self(self)
        collection.append(newElement)
        return collection
    }

    @inlinable
    func appending<S: Sequence>(contentsOf newElements: S) -> Self where Element == S.Element {
        var collection = Self(self)
        collection.append(contentsOf: newElements)
        return collection
    }

}
