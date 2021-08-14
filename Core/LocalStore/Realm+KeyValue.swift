// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import RealmSwift

// Replacement for user-unspecific `UserDefaults` in user-specific Realm stores.

public extension Realm {

    var string: AnySubscript<StoreKeyValueStringContainer, String> {
        return AnySubscript(store: self)
    }

    var int: AnySubscript<StoreKeyValueIntContainer, Int> {
        return AnySubscript(store: self)
    }

    var double: AnySubscript<StoreKeyValueDoubleContainer, Double> {
        return AnySubscript(store: self)
    }

    var bool: AnySubscript<StoreKeyValueBoolContainer, Bool> {
        return AnySubscript(store: self)
    }

    var data: AnySubscript<StoreKeyValueDataContainer, Data> {
        return AnySubscript(store: self)
    }

    var date: AnySubscript<StoreKeyValueDateContainer, Date> {
        return AnySubscript(store: self)
    }

    final class AnySubscript<Model: StoreKeyValueContainer, Value> {

        private let store: Realm

        fileprivate init(store: Realm) {
            self.store = store
        }

        public subscript(key: String) -> Value? {
            get {
                guard !(store.isMain && !LocalStore.shared.mainStoreIsInitialized.value) else { return nil }

                // Find and return if exists.
                let existingObjects = store.objects(Model.self).filter("key == %@", key)
                assert(existingObjects.count <= 1)
                return existingObjects.first?.value as? Value
            }

            set(value) {
                guard !(store.isMain && !LocalStore.shared.mainStoreIsInitialized.value) else { return }

                // Relying on the fact that `Model.self` is a singleton itself.
                synchronized(Model.self) {
                    if let value = value {
                        // Add or replace.
                        let object = Model()
                        object.key = key
                        object.value = value as! Model.Value
                        let existingObjects = store.objects(Model.self).filter("key == %@", key)
                        store.modify {
                            store.delete(existingObjects)
                            store.add(object)
                        }
                    } else {
                        // Delete.
                        let existingObjects = store.objects(Model.self).filter("key == %@", key)
                        store.modify {
                            store.delete(existingObjects)
                        }
                    }
                }
            }
        }

        public func removeValue(forKey key: String) {
            self[key] = nil
        }

    }

}

public protocol StoreKeyValueContainer where Self: RealmSwift.Object {
    associatedtype Value
    var key: String { get set }
    var value: Value { get set }
}

@objcMembers
public final class StoreKeyValueStringContainer: RealmSwift.Object, StoreKeyValueContainer {
    public dynamic var key = String()
    public dynamic var value = String()
}

@objcMembers
public final class StoreKeyValueIntContainer: RealmSwift.Object, StoreKeyValueContainer {
    public dynamic var key = String()
    public dynamic var value = Int()
}

@objcMembers
public final class StoreKeyValueDoubleContainer: RealmSwift.Object, StoreKeyValueContainer {
    public dynamic var key = String()
    public dynamic var value = Double()
}

@objcMembers
public final class StoreKeyValueBoolContainer: RealmSwift.Object, StoreKeyValueContainer {
    public dynamic var key = String()
    public dynamic var value = Bool()
}

@objcMembers
public final class StoreKeyValueDataContainer: RealmSwift.Object, StoreKeyValueContainer {
    public dynamic var key = String()
    public dynamic var value = Data()
}

@objcMembers
public final class StoreKeyValueDateContainer: RealmSwift.Object, StoreKeyValueContainer {
    public dynamic var key = String()
    public dynamic var value = Date()
}
