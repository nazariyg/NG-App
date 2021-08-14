// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension String {

    @inlinable
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    @inlinable
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }

    @inlinable
    func localized(comment: String = "", arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: comment), arguments: arguments)
    }

    @inlinable
    func localized(comment: String = "", arguments: [String]) -> String {
        return String(format: NSLocalizedString(self, comment: comment), arguments: arguments)
    }

    @inlinable
    func localized(forLocaleID localeID: String) -> String {
        guard let path = Bundle.main.path(forResource: localeID, ofType: "lproj") else { return self }
        guard let bundle = Bundle(path: path) else { return self }
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }

    @inlinable
    var localizedForEnglish: String {
        return localized(forLocaleID: "en")
    }

}
