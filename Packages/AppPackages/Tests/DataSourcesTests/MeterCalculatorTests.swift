import XCTest
import Model
import ModelStubs
@testable import DataSources

class MeterCalculatorTests: XCTestCase {
    
    func testMeterReading_weekday_beforeWork() throws {
        
        // Given
        let now = Date.weekday_0800_London
        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let reader = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = reader.calculateReading(at: now)
        
        // Then
        XCTAssertEqual(0, currentReading.amountEarned)
        XCTAssertEqual(0, currentReading.progress)
        XCTAssertEqual(.beforeWork, currentReading.status)
    }
    
    func testMeterReading_weekday_atWork() throws {

        // Given
        let now = Date.weekday_1300_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700)

        // When
        let reader = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = reader.calculateReading(at: now)

        // Then
        XCTAssertEqual(200, currentReading.amountEarned)
        XCTAssertEqual(0.5, currentReading.progress)
        XCTAssertEqual(.atWork, currentReading.status)
    }

    func testMeterReading_weekday_afterWork() throws {

        // Given
        let now = Date.weekday_1900_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700)

        // When
        let reader = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = reader.calculateReading(at: now)

        // Then
        XCTAssertEqual(400, currentReading.amountEarned)
        XCTAssertEqual(1, currentReading.progress)
        XCTAssertEqual(.afterWork, currentReading.status)
    }

    func testMeterReading_atWeekend_forWeekendWorker_showsReadingValue() throws {

        // Given
        let now = Date.weekend_1300_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700,
                                                 rate: .init(amount: 400, type: .daily),
                                                 runAtWeekends: true)

        // When
        let reader = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = reader.calculateReading(at: now)

        // Then
        XCTAssertEqual(200, currentReading.amountEarned)
        XCTAssertEqual(0.5, currentReading.progress)
        XCTAssertEqual(.atWork, currentReading.status)
    }

    func testMeterReading_atWeekend_forNonWeekendWorker_showsZeroReading() throws {

        // Given
        let now = Date.weekend_1300_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700,
                                                 runAtWeekends: false)

        // When
        let reader = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = reader.calculateReading(at: now)

        // Then
        XCTAssertEqual(0, currentReading.amountEarned)
        XCTAssertEqual(0, currentReading.progress)
        XCTAssertEqual(.dayOff, currentReading.status)
    }

    func testMeterReading_overnightWorker_beforeWork() throws {

        // Given
        let now = Date.weekday_1900_London
        let calendar = Calendar.iso8601(in: .london)
        let overnightMeter = MeterSettings.fake(ofType: .overnight_worker_2200_to_0600,
                                                runAtWeekends: false)


        // When
        let reader = MeterCalculator(meterSettings: overnightMeter, calendar: calendar)
        let currentReading = reader.calculateReading(at: now)

        // Then
        XCTAssertEqual(0, currentReading.amountEarned)
        XCTAssertEqual(0, currentReading.progress)
        XCTAssertEqual(.beforeWork, currentReading.status)
    }

    func testMeterReading_overnightWorker_atWork() throws {

        // Given
        let now = Date.weekday_0200_London
        let calendar = Calendar.iso8601(in: .london)
        let overnightMeter = MeterSettings.fake(ofType: .overnight_worker_2200_to_0600,
                                                runAtWeekends: false)

        // When
        let reader = MeterCalculator(meterSettings: overnightMeter, calendar: calendar)
        let currentReading = reader.calculateReading(at: now)
        
        // Then
        XCTAssertEqual(200, currentReading.amountEarned)
        XCTAssertEqual(0.5, currentReading.progress)
        XCTAssertEqual(.atWork, currentReading.status)

    }

    func testMeterReading_overnightWorker_afterWork() throws {

        // Given
        let now = Date.weekday_0800_London
        let calendar = Calendar.iso8601(in: .london)
        let overnightMeter = MeterSettings.fake(ofType: .overnight_worker_2200_to_0600,
                                                runAtWeekends: false)

        // When
        let reader = MeterCalculator(meterSettings: overnightMeter, calendar: calendar)
        let currentReading = reader.calculateReading(at: now)
        
        // Then
        XCTAssertEqual(400, currentReading.amountEarned)
        XCTAssertEqual(1, currentReading.progress)
        XCTAssertEqual(.afterWork, currentReading.status)

    }
}


extension Calendar {

    static func iso8601(in timeZone: TimeZone = .UTC) -> Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = timeZone
        return cal
    }
}
