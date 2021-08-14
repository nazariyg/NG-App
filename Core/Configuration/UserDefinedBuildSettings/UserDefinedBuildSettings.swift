// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

/// Reads user-defined build settings through a dictionary in Info.plist.
public final class UserDefinedBuildSettings {

    public static let string = TypeSubscript<String>(settingsDict: settingsDict)
    public static let bool = TypeSubscript<Bool>(settingsDict: settingsDict)
    public static let int = TypeSubscript<Int>(settingsDict: settingsDict)

    private static let infoDictKey = "UserDefinedBuildSettings"
    private static let settingsDict = Bundle.main.object(forInfoDictionaryKey: infoDictKey) as! [String: Any]

    public final class TypeSubscript<Type> {

        private let settingsDict: [String: Any]

        fileprivate init(settingsDict: [String: Any]) {
            self.settingsDict = settingsDict
        }

        public subscript(key: String) -> Type {
            return settingsDict[key] as! Type
        }

    }

}
