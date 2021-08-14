// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

private typealias StoredPropertiesStore = [String: Any]

private struct AssociatedKeys {
    static var store = "store"
    static var atomicStore = "atomicStore"
}

/// Allows for stored properties in protocol extensions of protocols that inherit from this protocol. This enables more flexible compositions with mixins.
public protocol StoredProperties: AnyObject {}

public extension StoredProperties {

    // MARK: - Non-atomic access.

    var storedProperties: StoredPropertiesStoreProvider {
        createStoreIfNeeded()
        return StoredPropertiesStoreProvider(object: self)
    }

    // Shortcut.
    var sp: StoredPropertiesStoreProvider {
        return storedProperties
    }

    // MARK: - Thread-safe access.

    var atomicStoredProperties: AtomicStoredPropertiesStoreProvider {
        createAtomicStoreIfNeeded()
        return AtomicStoredPropertiesStoreProvider(object: self)
    }

    // Shortcut.
    var asp: AtomicStoredPropertiesStoreProvider {
        return atomicStoredProperties
    }

    // MARK: - Store creation

    private func createStoreIfNeeded() {
        let existingWrappedStore = objc_getAssociatedObject(self, &AssociatedKeys.store) as? MutableValueWrapper<StoredPropertiesStore>
        if existingWrappedStore == nil {
            let wrappedStore = MutableValueWrapper(StoredPropertiesStore())
            objc_setAssociatedObject(self, &AssociatedKeys.store, wrappedStore, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private func createAtomicStoreIfNeeded() {
        synchronized(self) {
            let existingWrappedStore = objc_getAssociatedObject(self, &AssociatedKeys.atomicStore) as? MutableValueWrapper<StoredPropertiesStore>
            if existingWrappedStore == nil {
                let wrappedStore = MutableValueWrapper(StoredPropertiesStore())
                objc_setAssociatedObject(self, &AssociatedKeys.atomicStore, wrappedStore, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)  // NONATOMIC is Ok here
            }
        }
    }

}

public struct StoredPropertiesStoreProvider {

    public var any: StoredPropertiesSubscript<Any> {
        return StoredPropertiesSubscript(object: object)
    }

    public var string: StoredPropertiesSubscript<String> {
        return StoredPropertiesSubscript(object: object)
    }

    public var int: StoredPropertiesSubscript<Int> {
        return StoredPropertiesSubscript(object: object)
    }

    public var double: StoredPropertiesSubscript<Double> {
        return StoredPropertiesSubscript(object: object)
    }

    public var bool: StoredPropertiesSubscript<Bool> {
        return StoredPropertiesSubscript(object: object)
    }

    private var object: AnyObject

    fileprivate init(object: AnyObject) {
        self.object = object
    }

}

public struct AtomicStoredPropertiesStoreProvider {

    public var any: AtomicStoredPropertiesSubscript<Any> {
        return AtomicStoredPropertiesSubscript(object: object)
    }

    public var string: AtomicStoredPropertiesSubscript<String> {
        return AtomicStoredPropertiesSubscript(object: object)
    }

    public var int: AtomicStoredPropertiesSubscript<Int> {
        return AtomicStoredPropertiesSubscript(object: object)
    }

    public var double: AtomicStoredPropertiesSubscript<Double> {
        return AtomicStoredPropertiesSubscript(object: object)
    }

    public var bool: AtomicStoredPropertiesSubscript<Bool> {
        return AtomicStoredPropertiesSubscript(object: object)
    }

    private var object: AnyObject

    fileprivate init(object: AnyObject) {
        self.object = object
    }

}

public final class StoredPropertiesSubscript<Type> {

    private var object: AnyObject

    fileprivate init(object: AnyObject) {
        self.object = object
    }

    public subscript(key: String) -> Type? {
        get {
            if let wrappedStore = objc_getAssociatedObject(object, &AssociatedKeys.store) as? MutableValueWrapper<StoredPropertiesStore> {
                return wrappedStore.value[key] as? Type
            } else {
                return nil
            }
        }

        set(value) {
            if let wrappedStore = objc_getAssociatedObject(object, &AssociatedKeys.store) as? MutableValueWrapper<StoredPropertiesStore> {
                if let value = value {
                    wrappedStore.value[key] = value
                } else {
                    wrappedStore.value.removeValue(forKey: key)
                }
            }
        }
    }

}

public final class AtomicStoredPropertiesSubscript<Type> {

    private var object: AnyObject

    fileprivate init(object: AnyObject) {
        self.object = object
    }

    public subscript(key: String) -> Type? {
        get {
            return synchronized(object) {
                if let wrappedStore = objc_getAssociatedObject(object, &AssociatedKeys.atomicStore) as? MutableValueWrapper<StoredPropertiesStore> {
                    return wrappedStore.value[key] as? Type
                } else {
                    return nil
                }
            }
        }

        set(value) {
            synchronized(object) {
                if let wrappedStore = objc_getAssociatedObject(object, &AssociatedKeys.atomicStore) as? MutableValueWrapper<StoredPropertiesStore> {
                    if let value = value {
                        wrappedStore.value[key] = value
                    } else {
                        wrappedStore.value.removeValue(forKey: key)
                    }
                }
            }
        }
    }

}
