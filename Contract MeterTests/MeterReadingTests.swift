//
//  MeterReadingTests.swift
//  Earnings MeterTests
//
//  Created by Shilan Patel on 14/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import XCTest
@testable import Contract_Meter

class MeterReadingTests: XCTestCase {
    
    func testMeterReading_weekday_beforeWork() throws {
        
        // Given
        let calendar = Calendar.iso8601
        let fakeNow: () -> Date = { Date.weekday_0800_London }
        let environment = AppEnvironment.fake(date: fakeNow,
                                              currentCalendar: { calendar })

        let nineToFiveMeter = MeterSettings.day_worker_0900_to_1700(withDailyRate: 800)
        
        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()
        
        // Then
        XCTAssertEqual(0, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty, meterReader.currentReading.status)
    }
    
    func testMeterReading_weekday_atWork() throws {

        // Given
        let calendar = Calendar.iso8601
        let fakeNow: () -> Date = { Date.weekday_1300_London }
        let environment = AppEnvironment.fake(date: fakeNow,
                                              currentCalendar: { calendar })
        let nineToFiveMeter = MeterSettings.day_worker_0900_to_1700(withDailyRate: 800)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(400, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0.5, meterReader.currentReading.progress)
        XCTAssertEqual(.hired, meterReader.currentReading.status)
    }

    func testMeterReading_weekday_afterWork() throws {

        // Given
        let calendar = Calendar.iso8601
        let fakeNow: () -> Date = { Date.weekday_1900_London }
        let environment = AppEnvironment.fake(date: fakeNow,
                                              currentCalendar: { calendar })
        let nineToFiveMeter = MeterSettings.day_worker_0900_to_1700(withDailyRate: 800)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(800, meterReader.currentReading.amountEarned)
        XCTAssertEqual(1, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty, meterReader.currentReading.status)
    }

    func testMeterReading_atWeekend_forWeekendWorker_showsReadingValue() throws {

        // Given
        let calendar = Calendar.iso8601
        let fakeNow: () -> Date = { Date.weekend_1300_London }
        let environment = AppEnvironment.fake(date: fakeNow,
                                              currentCalendar: { calendar })
        
        let nineToFiveMeter = MeterSettings.day_worker_0900_to_1700(withDailyRate: 800,
                                                                    runAtWeekends: true)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(400, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0.5, meterReader.currentReading.progress)
        XCTAssertEqual(.hired, meterReader.currentReading.status)
    }

    func testMeterReading_atWeekend_forNonWeekendWorker_showsZeroReading() throws {

        // Given
        let calendar = Calendar.iso8601
        let fakeNow: () -> Date = { Date.weekend_1300_London }
        let environment = AppEnvironment.fake(date: fakeNow,
                                              currentCalendar: { calendar })
        let nineToFiveMeter = MeterSettings.day_worker_0900_to_1700(withDailyRate: 800,
                                                                    runAtWeekends: false)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(0, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty, meterReader.currentReading.status)
    }

    func testMeterReading_overnightWorker_beforeWork() throws {

        // Given
        let calendar = Calendar.iso8601
        let fakeNow: () -> Date = { Date.weekday_1900_London }
        let environment = AppEnvironment.fake(date: fakeNow,
                                              currentCalendar: { calendar })

        let overnightMeter = MeterSettings.overnight_worker_2200_to_0600(withDailyRate: 800,
                                                                         runAtWeekends: false)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: overnightMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(0, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty, meterReader.currentReading.status)
    }

    func testMeterReading_overnightWorker_atWork() throws {

        // Given
        let calendar = Calendar.iso8601
        let fakeNow: () -> Date = { Date.weekday_0200_London }
        let environment = AppEnvironment.fake(date: fakeNow,
                                              currentCalendar: { calendar })
        
        let overnightMeter = MeterSettings.overnight_worker_2200_to_0600(withDailyRate: 800,
                                                                         runAtWeekends: false)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: overnightMeter)
        meterReader.start()
        
        // Then
        XCTAssertEqual(400, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0.5, meterReader.currentReading.progress)
        XCTAssertEqual(.hired, meterReader.currentReading.status)

    }

    func testMeterReading_overnightWorker_afterWork() throws {

        // Given
        let calendar = Calendar.iso8601
        let fakeNow: () -> Date = { Date.weekday_0800_London }
        let environment = AppEnvironment.fake(date: fakeNow,
                                              currentCalendar: { calendar })
        
        let overnightMeter = MeterSettings.overnight_worker_2200_to_0600(withDailyRate: 800,
                                                                         runAtWeekends: false)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: overnightMeter)
        meterReader.start()
        
        // Then
        XCTAssertEqual(800, meterReader.currentReading.amountEarned)
        XCTAssertEqual(1, meterReader.currentReading.progress)
        XCTAssertEqual(.offDuty, meterReader.currentReading.status)

    }
}

private extension Date {
    
    static func weekday(hour: Int,
                        minute: Int,
                        in timeZone: TimeZone) -> Date {
        Date.iso8601(timeZone: timeZone,
                     year: 2020,
                     month: 7,
                     day: 14,
                     hour: hour,
                     minute: minute)!
    }
    
    static func weekend(hour: Int,
                        minute: Int,
                        in timeZone: TimeZone) -> Date {
        Date.iso8601(timeZone: timeZone,
                     year: 2020,
                     month: 7,
                     day: 12,
                     hour: hour,
                     minute: minute)!
    }
    
    static let weekday_0200_London = Date.weekday(hour: 2, minute: 0, in: .london)
    
    static let weekday_0800_London = Date.weekday(hour: 8, minute: 0, in: .london)
    
    static let weekday_1300_London = Date.weekday(hour: 13, minute: 0, in: .london)

    static let weekday_1900_London = Date.weekday(hour: 19, minute: 0, in: .london)
    
    static let weekend_1300_London = Date.weekend(hour: 13, minute: 0, in: .london)
}

