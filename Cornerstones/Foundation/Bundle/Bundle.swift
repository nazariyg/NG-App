// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension Bundle {

    @inlinable
    var id: String {
        return bundleIdentifier ?? "unknown.bundle.id"
    }

    @inlinable
    static var mainBundleID: String {
        return main.id
    }

    @inlinable
    static func forObject(_ object: AnyObject) -> Bundle {
        return Bundle(for: type(of: object))
    }

}
