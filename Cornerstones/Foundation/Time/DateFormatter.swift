// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public extension DateFormatter {

    /// "yyyy-MM-dd HH:mm:ss UTC"
    @inlinable
    static var utc: DateFormatter {
        let formatter = DateFormatter()
        with(formatter) {
            $0.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
            $0.timeZone = TimeZone(secondsFromGMT: 0)
            $0.locale = Locale(identifier: "en_US_POSIX")
        }
        return formatter
    }

    /// "yyyy-MM-ddTHH:mm:ssZ"
    @inlinable
    static var iso8601UTC: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        with(formatter) {
            $0.formatOptions = .withInternetDateTime
            $0.timeZone = TimeZone(secondsFromGMT: 0)
        }
        return formatter
    }

}
