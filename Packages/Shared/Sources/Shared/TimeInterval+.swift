import Foundation

// MARK: - TimeInterval
public extension TimeInterval {

    static func seconds(_ seconds: Int) -> TimeInterval {
        TimeInterval(seconds)
    }

    static func minutes(_ minutes: Int) -> TimeInterval {
        TimeInterval(minutes * 60)
    }

    static func hours(_ hours: Int) -> TimeInterval {
        TimeInterval(hours * 60 * 60)
    }
}

public extension Int {

    var seconds: TimeInterval {
        TimeInterval.seconds(self)
    }

    var minutes: TimeInterval {
        TimeInterval.minutes(self)
    }

    var hours: TimeInterval {
        TimeInterval.hours(self)
    }
}
