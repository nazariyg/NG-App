// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import CoreLocation
import RealmSwift

public extension List where Element: Equatable {

    static func compare(_ list1: List, _ list2: List) -> Bool {
        return Array(list1) == Array(list2)
    }

    static func == (list1: List, list2: List) -> Bool {
        return compare(list1, list2)
    }

    static func != (list1: List, list2: List) -> Bool {
        return !(list1 == list2)
    }

}

public extension List {

    func replace(with other: List<Element>) {
        removeAll()
        append(objectsIn: other)
    }

    func replace<CollectionType: Collection>(with other: CollectionType) where CollectionType.Element == Element {
        removeAll()
        append(objectsIn: other)
    }

}

public extension List where Element: Equatable {

    convenience init(_ array: [Element]) {
        self.init()
        append(objectsIn: array)
    }

    var array: [Element] {
        return [Element](self)
    }

}

public extension List where Element: Hashable {

    convenience init(_ set: Set<Element>) {
        self.init()
        append(objectsIn: set)
    }

    var set: Set<Element> {
        return Set<Element>(self)
    }

}

public extension Collection where Element: RealmCollectionValue {

    var storeList: List<Element> {
        let list = List<Element>()
        for element in self {
            list.append(element)
        }
        return list
    }

}
