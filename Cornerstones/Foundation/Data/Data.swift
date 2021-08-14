// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension Data {

    @inlinable
    var string: String? {
        return String(data: self, encoding: .utf8)
    }

    /// The produced string is in lower case.
    @inlinable
    var hexString: String {
        return
            self
            .map { String(format: "%02hhx", $0) }
            .joined()
    }

    @inlinable
    static func securelyGenerateRandomKey(bytesCount: Int) -> Data {
        var key = Data(count: bytesCount)
        _ = key.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, bytesCount, $0.baseAddress!)
        }
        return key
    }

}
