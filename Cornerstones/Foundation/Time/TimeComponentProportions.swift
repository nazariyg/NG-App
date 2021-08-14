// Copyright © 2021 Nazariy Gorpynyuk.
// All rights reserved.

import Foundation

public protocol TimeComponentProportions {
    init (_: Int)
}

public extension TimeComponentProportions {

    static var millisecondsInSecond: Self { Self(1000) }
    static var microsecondsInSecond: Self { Self(1000000) }
    static var nanosecondsInSecond: Self { Self(1000000000) }

    static var secondsInMinute: Self { Self(60) }
    static var secondsInHour: Self { Self(3600) }
    static var secondsInDay: Self { Self(86400) }
    static var secondsInWeek: Self { Self(604800) }
    static var secondsInMonth28: Self { Self(2419200) }
    static var secondsInMonth29: Self { Self(2505600) }
    static var secondsInMonth30: Self { Self(2592000) }
    static var secondsInMonth31: Self { Self(2678400) }
    static var secondsInCommonYear: Self { Self(31536000) }
    static var secondsInLeapYear: Self { Self(31622400) }

    static var minutesInHour: Self { Self(60) }
    static var minutesInDay: Self { Self(1440) }

}

extension Int: TimeComponentProportions {}
extension TimeInterval: TimeComponentProportions {}
