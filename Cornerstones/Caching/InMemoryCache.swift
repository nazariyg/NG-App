// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

private typealias NSCacheType = NSCache<NSString, AnyObject>

/// Thread-safe, in-memory key-value store based on NSCache. Keys are always strings.
public struct InMemoryCache {

    public init() {}

    public var string: AnySubscript<String> {
        return AnySubscript(cache: cache)
    }

    public var int: AnySubscript<Int> {
        return AnySubscript(cache: cache)
    }

    public var double: AnySubscript<Double> {
        return AnySubscript(cache: cache)
    }

    public var bool: AnySubscript<Bool> {
        return AnySubscript(cache: cache)
    }

    public var data: AnySubscript<Data> {
        return AnySubscript(cache: cache)
    }

    public func any<Type>(_: Type.Type) -> AnySubscript<Type> {
        return AnySubscript(cache: cache)
    }

    public func removeValue(forKey key: String) {
        cache.removeObject(forKey: NSString(string: key))
    }

    private let cache = NSCacheType()

    public final class AnySubscript<Type> {

        private let cache: NSCacheType

        fileprivate init(cache: NSCacheType) {
            self.cache = cache
        }

        public subscript(key: String) -> Type? {
            get {
                let optionalAnyWrapper = cache.object(forKey: NSString(string: key)) as? AnyWrapper
                if let anyWrapper = optionalAnyWrapper {
                    return anyWrapper.value as? Type
                } else {
                    return nil
                }
            }

            set(value) {
                if let value = value {
                    cache.setObject(AnyWrapper(value), forKey: NSString(string: key))
                } else {
                    cache.removeObject(forKey: NSString(string: key))
                }
            }
        }

    }

}
