//
//  Date+.swift
//  Earnings Meter
//
//  Created by Shilan Patel on 21/01/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import Foundation

extension TimeZone {
    
    static let UTC = TimeZone(abbreviation: "UTC")!
    static let newYork = TimeZone(identifier: "America/New_York")!
    static let london = TimeZone(identifier: "Europe/London")!
}

extension Calendar {
    
    static let iso8601 = Calendar(identifier: .iso8601)
    
    static let iso8601UTC: Calendar = {
        return iso8601(in: .UTC)
    }()
    
    static func iso8601(in timeZone: TimeZone = .UTC) -> Calendar {
        var cal = Calendar.iso8601
        cal.timeZone = timeZone
        return cal
    }
}

extension Date {
    
    static func UTC(year: Int = 1970,
                    month: Int = 1,
                    day: Int = 1,
                    hour: Int = 0,
                    minute: Int = 0,
                    second: Int = 0,
                    nanosecond: Int = 0) -> Date? {
        
        let cal = Calendar.iso8601(in: .UTC)
        let comps = DateComponents(calendar: cal,
                                   timeZone: .UTC,
                                   year: year,
                                   month: month,
                                   day: day,
                                   hour: hour,
                                   minute: minute,
                                   second: second,
                                   nanosecond: nanosecond)
        return cal.date(from: comps)
    }
}


public protocol DateGeneratorType {
    var now: Date { get }
}

public struct DateGenerator: DateGeneratorType {
    
    public static let `default` = DateGenerator()
    
    public var now: Date {
        Date()
    }
}

final class FakeDateGenerator: DateGeneratorType {
    var now: Date
    
    init(now: Date = Date()) {
        self.now = now
    }
}
