// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import UIKit

extension UIDevice {

    static func pixelsPerInch(fromIdentifier identifier: String) -> Double {  // swiftlint:disable:this cyclomatic_complexity
        #if os(iOS)
            switch identifier {

            case "iPod5,1": return 326
            case "iPod7,1": return 326

            case "iPhone3,1", "iPhone3,2", "iPhone3,3": return 326
            case "iPhone4,1": return 326
            case "iPhone5,1", "iPhone5,2": return 326
            case "iPhone5,3", "iPhone5,4": return 326
            case "iPhone6,1", "iPhone6,2": return 326
            case "iPhone7,2": return 326
            case "iPhone7,1": return 401
            case "iPhone8,1": return 326
            case "iPhone8,2": return 401
            case "iPhone9,1", "iPhone9,3": return 326
            case "iPhone9,2", "iPhone9,4": return 401
            case "iPhone8,4": return 326
            case "iPhone10,1", "iPhone10,4": return 326
            case "iPhone10,2", "iPhone10,5": return 401
            case "iPhone10,3", "iPhone10,6": return 458
            case "iPhone11,2": return 458
            case "iPhone11,4", "iPhone11,6": return 458
            case "iPhone11,8": return 326
            case "iPhone12,1": return 326
            case "iPhone12,3": return 458
            case "iPhone12,5": return 458
            case "iPhone12,8": return 326
            case "iPhone13,1": return 476
            case "iPhone13,2": return 460
            case "iPhone13,3": return 460
            case "iPhone13,4": return 458

            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return 132
            case "iPad3,1", "iPad3,2", "iPad3,3": return 264
            case "iPad3,4", "iPad3,5", "iPad3,6": return 264
            case "iPad4,1", "iPad4,2", "iPad4,3": return 264
            case "iPad5,3", "iPad5,4": return 264
            case "iPad6,11", "iPad6,12": return 264
            case "iPad7,5", "iPad7,6": return 264
            case "iPad2,5", "iPad2,6", "iPad2,7": return 163
            case "iPad4,4", "iPad4,5", "iPad4,6": return 326
            case "iPad4,7", "iPad4,8", "iPad4,9": return 326
            case "iPad5,1", "iPad5,2": return 326
            case "iPad6,3", "iPad6,4": return 264
            case "iPad6,7", "iPad6,8": return 264
            case "iPad7,1", "iPad7,2": return 264
            case "iPad7,3", "iPad7,4": return 264
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return 264
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return 264

            case "i386", "x86_64": return pixelsPerInch(fromIdentifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "")

            default: return Self.defaultPixelsPerInch
            }
        #elseif os(tvOS)
            return Self.defaultPixelsPerInch
        #endif
    }

    private static var defaultPixelsPerInch: Double {
        assertionFailure("Time to update the list for new device models?")
        return 326
    }

}
