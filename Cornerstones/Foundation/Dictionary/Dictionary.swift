// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension Dictionary where Value: Equatable {

    @inlinable
    func allKeys(forValue value: Value) -> [Key] {
        return compactMap { k, v in
            return v == value ? k : nil
        }
    }

    @inlinable
    func anyKey(forValue value: Value) -> Key? {
        for (k, v) in self where v == value {
            return k
        }
        return nil
    }

}

public extension Dictionary {

    @inlinable
    mutating func mergeReplacing(dictionary: Dictionary) {
        merge(dictionary) { (_, new) in new }
    }

    @inlinable
    mutating func mergeKeeping(dictionary: Dictionary) {
        merge(dictionary) { (current, _) in current }
    }

    @inlinable
    func mergingWithReplacing(dictionary: Dictionary) -> Dictionary {
        return merging(dictionary) { (_, new) in new }
    }

    @inlinable
    func mergingWithKeeping(dictionary: Dictionary) -> Dictionary {
        return merging(dictionary) { (current, _) in current }
    }

}

public extension Dictionary {

    @inlinable
    var prettyPrinted: String {
        return "\(self as AnyObject)"
    }

}
