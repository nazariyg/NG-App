// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation
import CommonCrypto

public extension Data {

    @inlinable
    var md5: Data {
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes.baseAddress, CC_LONG(self.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
            }
        }
        return digestData
    }

    @inlinable
    var sha256: Data {
        var digestData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            withUnsafeBytes { messageBytes in
                CC_SHA256(messageBytes.baseAddress, CC_LONG(self.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
            }
        }
        return digestData
    }

}
