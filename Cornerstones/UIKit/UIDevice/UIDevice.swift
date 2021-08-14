// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

extension UIDevice: StoredProperties {

    // MARK: - Device Info

    /// Returns the iOS's version.
    public var iosVersion: String {
        return systemVersion
    }

    /// Returns the device's model.
    public var modelName: String {
        synchronized(self) {
            if let modelName = storedProperties.string[#function] {
                return modelName
            }

            let modelName = Self.modelName(fromIdentifier: machineIdentifier)
            storedProperties.string[#function] = modelName

            return modelName
        }
    }

    /// Returns the device's PPI.
    public var pixelsPerInch: Double {
        synchronized(self) {
            if let pixelsPerInch = storedProperties.double[#function] {
                return pixelsPerInch
            }

            let pixelsPerInch = Self.pixelsPerInch(fromIdentifier: machineIdentifier)
            storedProperties.double[#function] = pixelsPerInch

            return pixelsPerInch
        }
    }

    /// Returns whether currently running on an iPhone.
    public var isPhone: Bool {
        return userInterfaceIdiom == .phone
    }

    /// Returns whether currently running on an iPad.
    public var isPad: Bool {
        return userInterfaceIdiom == .pad
    }

    /// Returns whether currently running on an Apple TV.
    public var isTV: Bool {
        return userInterfaceIdiom == .tv
    }

    /// Returns whether the device has a native screen.
    public var hasNativeScreen: Bool {
        return isPhone || isPad
    }

    /// Returns whether this is one of the small screen (iPhone 5/SE) models.
    public var hasSmallScreen: Bool {
        let hasSmallScreen = UIScreen.main.bounds.width <= 320.0
        return hasSmallScreen
    }

    /// Returns whether this is an iPhone with a rounded screen.
    public var hasScreenWithRoundedCorners: Bool {
        synchronized(self) {
            if let hasRoundedCorners = storedProperties.bool[#function] {
                return hasRoundedCorners
            }

            let id =
                machineIdentifier
                .trimmed()
                .replacingOccurrences(of: "^iPhone", with: "", options: .regularExpression)
                .replacingOccurrences(of: ",", with: "")
            guard let numericID = Int(id) else {
                assertionFailure()
                return false
            }

            let hasRoundedCorners =
                numericID >= 103 &&  // iPhone X or newer
                numericID != 104 &&  // not iPhone 8
                numericID != 105 &&  // not iPhone 8 Plus
                numericID != 128  // not iPhone SE 2nd Gen

            storedProperties.bool[#function] = hasRoundedCorners

            return hasRoundedCorners
        }
    }

    /// The Apple's API returns a different device ID for every app installation. Therefore, we reuse the first ID we get or generate our own ID and
    /// use a permanent store to keep the ID in, without synchronizing the ID across devices.
    public var persistentID: String {
        synchronized(self) {
            if let persistentID = storedProperties.string[#function] {
                return persistentID
            }

            let persistentID: String

            let store = KeychainStore.local
            let deviceIDKey = "deviceID"
            if let storedID = store.string[deviceIDKey] {
                persistentID = storedID
            } else {
                persistentID = UUID().uuidString
                store.string[deviceIDKey] = persistentID
            }
            storedProperties.string[#function] = persistentID

            return persistentID
        }
    }

    private var machineIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

}
