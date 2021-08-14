// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import Cornerstones
import RealmSwift

// MARK: - Protocol

public protocol LocalStoreProtocol {

    static var main: Realm { get }
    var main: Realm { get }

    static var `default`: Realm { get }
    var `default`: Realm { get }

    func initializeMainStore(forID storeID: String)
    func forgetMainStore()

    var mainStoreIsInitialized: P<Bool> { get }

}

// MARK: - Implementation

/// The main store is associated with a specific user and is initialized by the `UserService`. Any globally available data is stored in the default store,
/// which is initialized automatically. When the user logs out, the main store gets "forgotten" but remains retained in case if any deferred operation
/// will need access to the store associated with the previously logged in user.
public final class LocalStore: LocalStoreProtocol, SharedInstance {

    public typealias InstanceProtocol = LocalStoreProtocol
    public static func defaultInstance() -> InstanceProtocol { return LocalStore() }
    public static let doesReinstantiate = true

    static let _mainStoreFileNamePrefix = "MainPersistencyStore."
    static let _defaultStoreFileNamePrefix = "DefaultPersistencyStore."
    private static let storeCreationDirectoryURL = FileManager.documentsURL
    private static let storeFileExtension = "realm"
    private static let encryptStore = true
    private static var kcKeyForStoreSpecialWrench: String { "kcKeyForStoreSpecialWrench".md5 }

    public private(set) lazy var mainStoreIsInitialized = P(_mainStoreIsInitialized)
    private let _mainStoreIsInitialized = V<Bool>(false)

    private var currentMainStoreConfiguration: Realm.Configuration?
    private var forgottenMainStoreConfiguration: Realm.Configuration?
    private var currentDefaultStoreConfiguration: Realm.Configuration?
    private let mainStoreLock = VoidObject()
    private let defaultStoreLock = VoidObject()

    // MARK: - Lifecycle

    private init() {
        // Disable Realm's "new version available" notification in the console.
        setenv("REALM_DISABLE_UPDATE_CHECKER", "1", 1)

        initializeDefaultStore()
    }

    // MARK: - Main store

    public static var main: Realm {
        return Self.shared.main
    }

    public var main: Realm {
        return synchronized(mainStoreLock) {
            if _mainStoreIsInitialized.value {
                if let currentMainStoreConfiguration = currentMainStoreConfiguration,
                   let mainStore = getOrCreateMainStore(forConfiguration: currentMainStoreConfiguration) {

                    return mainStore
                }
            } else {
                // If a deferred operation is trying to access an already forgotten main store, provide that main store as a concession.
                if let forgottenMainStoreConfiguration = forgottenMainStoreConfiguration,
                   let mainStore = getOrCreateMainStore(forConfiguration: forgottenMainStoreConfiguration) {

                    return mainStore
                }
            }

            return `default`
        }
    }

    public func initializeMainStore(forID storeID: String) {
        synchronized(mainStoreLock) {
            guard getOrCreateQueueGlobalMainStore(forID: storeID) != nil else { return }
            forgottenMainStoreConfiguration = nil
            _mainStoreIsInitialized.value = true
        }
    }

    public func forgetMainStore() {
        synchronized(mainStoreLock) {
            forgottenMainStoreConfiguration = currentMainStoreConfiguration
            currentMainStoreConfiguration = nil
            _mainStoreIsInitialized.value = false
        }
    }

    // MARK: - Default store

    public static var `default`: Realm {
        return Self.shared.default
    }

    public var `default`: Realm {
        return synchronized(defaultStoreLock) {
            if let currentDefaultStoreConfiguration = currentDefaultStoreConfiguration,
               let defaultStore = getOrCreateDefaultStore(forConfiguration: currentDefaultStoreConfiguration) {

                return defaultStore
            }

            assertionFailure("The default store is not initialized")
            return try! Realm()
        }
    }

    private func initializeDefaultStore() {
        synchronized(defaultStoreLock) {
            _ = getOrCreateQueueGlobalDefaultStore()
        }
    }

    // MARK: - Private

    private func baseStoreConfiguration() -> Realm.Configuration {
        var configuration =
            Realm.Configuration(
                schemaVersion: UInt64(LocalStoreMigrations.currentSchemaVersion),
                migrationBlock: LocalStoreMigrations.migrationClosure)

        configuration.deleteRealmIfMigrationNeeded = Config.shared.general.deletePersistentStoreIfMigrationNeeded

        if Self.encryptStore {
            let specialWrench: Data
            if let data = KeychainStore.local.data[Self.kcKeyForStoreSpecialWrench] {
                specialWrench = data
            } else {
                specialWrench = Data.securelyGenerateRandomKey(bytesCount: 64)
                KeychainStore.local.data[Self.kcKeyForStoreSpecialWrench] = specialWrench
            }

            configuration.encryptionKey = specialWrench
        }

        return configuration
    }

    private func mainStoreConfiguration(forID storeID: String) -> Realm.Configuration {
        let storeName = storeID.isAlphanumeric ? storeID : storeID.md5
        var configuration = baseStoreConfiguration()
        let fileName = "\(Self._mainStoreFileNamePrefix)ID-\(storeName).\(Self.storeFileExtension)"
        configuration.fileURL = Self.storeCreationDirectoryURL.appendingPathComponent(fileName)
        return configuration
    }

    private func getOrCreateQueueGlobalMainStore(forID id: String) -> Realm? {
        let configuration = mainStoreConfiguration(forID: id)

        var store: Realm?
        do {
            store = try Realm(configuration: configuration)
            currentMainStoreConfiguration = configuration
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }

        // Prepare accessing Realm while the device is locked.
        store?.enableBackgroundAccess()

        return store
    }

    private func getOrCreateMainStore(forConfiguration configuration: Realm.Configuration) -> Realm? {
        var store: Realm?
        do {
            store = try Realm(configuration: configuration)
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }

        return store
    }

    private func defaultStoreConfiguration() -> Realm.Configuration {
        var configuration = baseStoreConfiguration()
        let fileName = "\(Self._defaultStoreFileNamePrefix)\(Self.storeFileExtension)"
        configuration.fileURL = Self.storeCreationDirectoryURL.appendingPathComponent(fileName)
        return configuration
    }

    @discardableResult
    private func getOrCreateQueueGlobalDefaultStore() -> Realm? {
        let configuration = defaultStoreConfiguration()

        var store: Realm?
        do {
            store = try Realm(configuration: configuration)
            currentDefaultStoreConfiguration = configuration
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }

        // Prepare accessing Realm while the device is locked.
        store?.enableBackgroundAccess()

        return store
    }

    private func getOrCreateDefaultStore(forConfiguration configuration: Realm.Configuration) -> Realm? {
        var store: Realm?
        do {
            store = try Realm(configuration: configuration)
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }

        return store
    }

}
