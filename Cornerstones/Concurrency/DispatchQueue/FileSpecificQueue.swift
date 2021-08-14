// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension DispatchQueue {

    /// Returns a serial queue with a label composed of the bundle ID, followed by a dot, and followed by the name of the file from where the method
    /// is called, without the file extension, and optionally followed by a custom label suffix.
    static func fileSpecificSerialQueue(qos: DispatchQoS, labelSuffix: String = "", filePath: String = #file) -> DispatchQueue {
        let label = uniqueQueueLabel(labelSuffix: labelSuffix, filePath: filePath)
        let queue = DispatchQueue(label: label, qos: qos)
        return queue
    }

    /// Returns a concurrent queue with a label composed of the bundle ID, followed by a dot, and followed by the name of the file from where the method
    /// is called, without the file extension, and optionally followed by a custom label suffix.
    static func fileSpecificConcurrentQueue(qos: DispatchQoS, labelSuffix: String = "", filePath: String = #file) -> DispatchQueue {
        let label = uniqueQueueLabel(labelSuffix: labelSuffix, filePath: filePath)
        let queue = DispatchQueue(label: label, qos: qos, attributes: .concurrent)
        return queue
    }

    /// Returns a label composed of the bundle ID, followed by a dot, and followed by the name of the file from where the method is called,
    /// without the file extension, optionally followed by a custom label suffix, and concluded by a random ID.
    static func uniqueQueueLabel(labelSuffix: String = "", filePath: String = #file) -> String {
        var fileName = URL(fileURLWithPath: filePath).deletingPathExtension().lastPathComponent
        fileName = fileName.replacingOccurrences(of: "\\W", with: "", options: .regularExpression)
        var label = "\(Bundle.mainBundleID).\(fileName)"
        if !labelSuffix.isEmpty {
            let labelSuffixWithoutLeadingDot = labelSuffix.replacingOccurrences(of: "^\\.", with: "", options: .regularExpression)
            label += ".\(labelSuffixWithoutLeadingDot)"
        }
        label += "-\(String.randomID())"
        return label
    }

}
