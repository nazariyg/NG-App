// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import KeychainAccess

public struct KeychainStore {

    // All keychains should be accessible while the app is in the background state.
    // A keychain that is local to the device and should not synchronize across devices over iCloud.
    public static let local = KeychainStore(storeType: .local)
    // A keychain that should synchronize across devices over iCloud.
    public static let global = KeychainStore(storeType: .global)

    public let string: StringSubscript
    public let int: IntSubscript
    public let double: DoubleSubscript
    public let bool: BoolSubscript
    public let data: DataSubscript

    public func removeValue(forKey key: String) {
        try? keychain.remove(key)
    }

    private enum StoreType {
        case local
        case global
    }

    private let keychain: Keychain

    private init(storeType: StoreType) {
        let bundleID = Bundle.mainBundleID
        switch storeType {
        case .local:
            let serviceName = "\(bundleID).local"
            keychain =
                Keychain(service: serviceName)
                .accessibility(.afterFirstUnlock)  // for background access
                .synchronizable(false)
        case .global:
            let serviceName = "\(bundleID).global"
            keychain =
                Keychain(service: serviceName)
                .accessibility(.afterFirstUnlock)  // for background access
                .synchronizable(true)
        }

        string = StringSubscript(keychain: keychain)
        int = IntSubscript(keychain: keychain)
        double = DoubleSubscript(keychain: keychain)
        bool = BoolSubscript(keychain: keychain)
        data = DataSubscript(keychain: keychain)
    }

    public final class StringSubscript {

        private let keychain: Keychain

        fileprivate init(keychain: Keychain) {
            self.keychain = keychain
        }

        public subscript(key: String) -> String? {
            get {
                let stringValue = try? keychain.getString(key)
                return stringValue
            }

            set(value) {
                if let value = value {
                    try? keychain.set(value, key: key)
                } else {
                    try? keychain.remove(key)
                }
            }
        }

    }

    public final class IntSubscript {

        private let keychain: Keychain

        fileprivate init(keychain: Keychain) {
            self.keychain = keychain
        }

        public subscript(key: String) -> Int? {
            get {
                guard let stringValue = try? keychain.getString(key) else { return nil }
                return Int(stringValue)
            }

            set(value) {
                if let value = value {
                    try? keychain.set(String(value), key: key)
                } else {
                    try? keychain.remove(key)
                }
            }
        }

    }

    public final class DoubleSubscript {

        private let keychain: Keychain

        fileprivate init(keychain: Keychain) {
            self.keychain = keychain
        }

        public subscript(key: String) -> Double? {
            get {
                guard let stringValue = try? keychain.getString(key) else { return nil }
                return Double(stringValue)
            }

            set(value) {
                if let value = value {
                    try? keychain.set(String(value), key: key)
                } else {
                    try? keychain.remove(key)
                }
            }
        }

    }

    public final class BoolSubscript {

        private let keychain: Keychain

        fileprivate init(keychain: Keychain) {
            self.keychain = keychain
        }

        public subscript(key: String) -> Bool? {
            get {
                guard let stringValue = try? keychain.getString(key) else { return nil }
                return Bool(stringValue)
            }

            set(value) {
                if let value = value {
                    try? keychain.set(String(value), key: key)
                } else {
                    try? keychain.remove(key)
                }
            }
        }

    }

    public final class DataSubscript {

        private let keychain: Keychain

        fileprivate init(keychain: Keychain) {
            self.keychain = keychain
        }

        public subscript(key: String) -> Data? {
            get {
                let dataValue = try? keychain.getData(key)
                return dataValue
            }

            set(value) {
                if let value = value {
                    try? keychain.set(value, key: key)
                } else {
                    try? keychain.remove(key)
                }
            }
        }

    }

}
