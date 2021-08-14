// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension String {

    // `_` to avoid conflict with `isNotEmpty` declared in RxOptional.
    @inlinable
    var _isNotEmpty: Bool {
        return !isEmpty
    }

    @inlinable
    func trimmed() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    @inlinable
    func removingAllWhitespaceAndNewlines() -> String {
        return replacingOccurrences(of: CharacterSet.whitespacesAndNewlines, with: "")
    }

    @inlinable
    func trimmedRemovingAllNewlines() -> String {
        let trimmed = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let newlineless = trimmed.replacingOccurrences(of: CharacterSet.newlines, with: "")
        return newlineless
    }

    @inlinable
    var isAlphanumeric: Bool {
        guard _isNotEmpty else { return false }
        let isAlphanumeric = range(of: "\\W", options: .regularExpression) == nil
        return isAlphanumeric
    }

    @inlinable
    func contains(substring: String) -> Bool {
        return range(of: substring) != nil
    }

    @inlinable
    func containsCaseInsensitive(substring: String) -> Bool {
        return range(of: substring, options: .caseInsensitive) != nil
    }

    @inlinable
    func countOccurrences(ofSubstring substring: String) -> Int {
        guard _isNotEmpty && substring._isNotEmpty else { return 0 }
        var numOccurrences = 0
        var currentSearchRange: Range<String.Index>?
        while let foundRange = range(of: substring, options: [], range: currentSearchRange) {
            numOccurrences += 1
            currentSearchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return numOccurrences
    }

    @inlinable
    func countOccurrences(ofCharacterSet characterSet: CharacterSet) -> Int {
        guard _isNotEmpty else { return 0 }
        var numOccurrences = 0
        var currentSearchRange: Range<String.Index>?
        while let foundRange = rangeOfCharacter(from: characterSet, options: [], range: currentSearchRange) {
            numOccurrences += 1
            currentSearchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return numOccurrences
    }

    @inlinable
    func snakecased() -> String {
        return replacingOccurrences(of: "([a-z])([A-Z])", with: "$1_$2", options: .regularExpression).lowercased()
    }

    @inlinable
    func dashcased() -> String {
        return replacingOccurrences(of: "([a-z])([A-Z])", with: "$1-$2", options: .regularExpression).lowercased()
    }

    @inlinable
    func replacingOccurrences(of target: CharacterSet, with replacement: String) -> String {
        return components(separatedBy: target).joined(separator: replacement)
    }

    @inlinable
    func padWithZeros(toLength length: Int) -> String {
        var string = self
        while string.count < length { string = "0\(string)" }
        return string
    }

    @inlinable
    static func randomID() -> String {
        return UUID().uuidString
    }

    @inlinable
    init?(decodingBase64String string: String) {
        guard let data = Data(base64Encoded: string) else { return nil }
        self.init(data: data, encoding: .utf8)
    }

}

public extension String.SubSequence {

    @inlinable
    var string: String {
        return String(self)
    }

}
