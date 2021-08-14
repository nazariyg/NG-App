// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public struct FileSize {

    public let bytes: UInt64

    private static let K1: UInt64 = 1024
    private static let K2: UInt64 = K1*K1
    private static let K3: UInt64 = K2*K1
    private static let K4: UInt64 = K3*K1

    public init(bytes: UInt64) {
        self.bytes = bytes
    }

    public init(kilobytes: UInt64) {
        self.init(bytes: kilobytes*Self.K1)
    }

    public init(megabytes: UInt64) {
        self.init(bytes: megabytes*Self.K2)
    }

    public init(gigabytes: UInt64) {
        self.init(bytes: gigabytes*Self.K3)
    }

    public init(terabytes: UInt64) {
        self.init(bytes: terabytes*Self.K4)
    }

    public var kilobytes: Double {
        let kilobytes = Double(bytes)/Double(Self.K1)
        return kilobytes
    }

    public var megabytes: Double {
        let megabytes = Double(bytes)/Double(Self.K2)
        return megabytes
    }

    public var gigabytes: Double {
        let gigabytes = Double(bytes)/Double(Self.K3)
        return gigabytes
    }

    public var terabytes: Double {
        let terabytes = Double(bytes)/Double(Self.K4)
        return terabytes
    }

}
