//
//  MeterReadingTests.swift
//  Earnings MeterTests
//
//  Created by Shilan Patel on 14/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import XCTest
@testable import Earnings_Meter

class MeterReadingTests: XCTestCase {

    func testMeterReading_weekday_beforeWork() throws {
        
        // Given
        let nineToFiveMeter = AppState.MeterSettings.day_worker_0900_to_1700(withDailyRate: 800)
        let calendar = Calendar.iso8601(in: .london)
        let now: Date = .weekday_0800_London
        
        // When
        let meterReader = MeterReader(meterSettings: nineToFiveMeter,
                                      calendar: calendar,
                                      dateGenerator: FakeDateGenerator(fakeNow: now))
        meterReader.start()
        
        // Then
        XCTAssertEqual(0, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty(.notStarted), meterReader.currentReading.status)
    }
    
    func testMeterReading_weekday_atWork() throws {
        
        // Given
        let meterSettings = AppState.MeterSettings.day_worker_0900_to_1700(withDailyRate: 800,
                                                                           runAtWeekends: false)
        let calendar = Calendar.iso8601(in: .london)
        let now: Date = .weekday_1300_London
        
        // When
        let meterReader = MeterReader(meterSettings: meterSettings,
                                      calendar: calendar,
                                      dateGenerator: FakeDateGenerator(fakeNow: now))
        meterReader.start()
        
        // Then
        XCTAssertEqual(400, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0.5, meterReader.currentReading.progress)
        XCTAssertEqual(.hired, meterReader.currentReading.status)
    }
    
    func testMeterReading_weekday_afterWork() throws {
        
        // Given
        let meterSettings = AppState.MeterSettings.day_worker_0900_to_1700(withDailyRate: 800,
                                                                           runAtWeekends: false)
        let calendar = Calendar.iso8601(in: .london)
        let now: Date = .weekday_1900_London
        
        // When
        let meterReader = MeterReader(meterSettings: meterSettings,
                                      calendar: calendar,
                                      dateGenerator: FakeDateGenerator(fakeNow: now))
        meterReader.start()
        
        // Then
        XCTAssertEqual(800, meterReader.currentReading.amountEarned)
        XCTAssertEqual(1, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty(.finished), meterReader.currentReading.status)
    }
    
    func testMeterReading_atWeekend_forWeekendWorker_showsReadingValue() throws {
        
        // Given
        let meterSettings = AppState.MeterSettings.day_worker_0900_to_1700(withDailyRate: 800,
                                                                           runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        let now: Date = .weekend_1300_London
        
        // When
        let meterReader = MeterReader(meterSettings: meterSettings,
                                      calendar: calendar,
                                      dateGenerator: FakeDateGenerator(fakeNow: now))
        meterReader.start()
        
        // Then
        XCTAssertEqual(400, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0.5, meterReader.currentReading.progress)
        XCTAssertEqual(.hired, meterReader.currentReading.status)
    }
    
    func testMeterReading_atWeekend_forNonWeekendWorker_showsZeroReading() throws {
        
        // Given
        let meterSettings = AppState.MeterSettings.day_worker_0900_to_1700(withDailyRate: 800,
                                                                           runAtWeekends: false)
        let calendar = Calendar.iso8601(in: .london)
        let now: Date = .weekend_1300_London
        
        // When
        let meterReader = MeterReader(meterSettings: meterSettings,
                                      calendar: calendar,
                                      dateGenerator: FakeDateGenerator(fakeNow: now))
        meterReader.start()
        
        // Then
        XCTAssertEqual(0, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty(.dayOff), meterReader.currentReading.status)
    }
    
    func testMeterReading_overnightWorker_beforeWork() throws {
        
        // Given
        let meterSettings = AppState.MeterSettings.overnight_worker_2200_to_0600(withDailyRate: 800)
        let calendar = Calendar.iso8601(in: .london)
        let now: Date = .weekday_1900_London
        
        // When
        let meterReader = MeterReader(meterSettings: meterSettings,
                                      calendar: calendar,
                                      dateGenerator: FakeDateGenerator(fakeNow: now))
        meterReader.start()
        
        // Then
        XCTAssertEqual(0, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty(.notStarted), meterReader.currentReading.status)
    }
    
    func testMeterReading_overnightWorker_atWork() throws {
        
        // Given
        let meterSettings = AppState.MeterSettings.overnight_worker_2200_to_0600(withDailyRate: 800)
        let calendar = Calendar.iso8601(in: .london)
        let now: Date = .weekday_0200_London
        
        // When
        let meterReader = MeterReader(meterSettings: meterSettings,
                                      calendar: calendar,
                                      dateGenerator: FakeDateGenerator(fakeNow: now))
        meterReader.start()
        
        // Then
        XCTAssertEqual(400, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0.5, meterReader.currentReading.progress)
        XCTAssertEqual(.hired, meterReader.currentReading.status)
    }
    
    func testMeterReading_overnightWorker_afterWork() throws {
        
        // Given
        let meterSettings = AppState.MeterSettings.overnight_worker_2200_to_0600(withDailyRate: 800)
        let calendar = Calendar.iso8601(in: .london)
        let now: Date = .weekday_0800_London
        
        // When
        let meterReader = MeterReader(meterSettings: meterSettings,
                                      calendar: calendar,
                                      dateGenerator: FakeDateGenerator(fakeNow: now))
        meterReader.start()
        
        // Then
        XCTAssertEqual(800, meterReader.currentReading.amountEarned)
        XCTAssertEqual(1, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty(.finished), meterReader.currentReading.status)
    }
}

private extension Date {
    
    static func weekday(at meterTime: MeterTime,
                        in timeZone: TimeZone,
                        calendar: Calendar = .iso8601) -> Date {
        calendar.date(from: .init(timeZone: timeZone,
                                  year: 2020,
                                  month: 7,
                                  day: 14,
                                  hour: meterTime.hour,
                                  minute: meterTime.minute))!
    }
    
    static func weekend(at meterTime: MeterTime,
                        in timeZone: TimeZone,
                        calendar: Calendar = .iso8601) -> Date {
        calendar.date(from: .init(timeZone: timeZone,
                                  year: 2020,
                                  month: 7,
                                  day: 12,
                                  hour: meterTime.hour,
                                  minute: meterTime.minute))!
    }
    
    static let weekday_0200_London = Date.weekday(at: .init(hour: 2, minute: 0),
                                                  in: .london)
    
    static let weekday_0800_London = Date.weekday(at: .init(hour: 8, minute: 0),
                                                  in: .london)
    
    static let weekday_1300_London = Date.weekday(at: .init(hour: 13, minute: 0),
                                                  in: .london)

    static let weekday_1900_London = Date.weekday(at: .init(hour: 19, minute: 0),
                                                  in: .london)
    
    static let weekend_1300_London = Date.weekend(at: .init(hour: 13, minute: 0),
                                                  in: .london)
}

