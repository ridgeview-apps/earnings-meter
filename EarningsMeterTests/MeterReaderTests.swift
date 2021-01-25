import XCTest
@testable import Earnings_Meter

class MeterReaderTests: XCTestCase {
    
    func testMeterReading_weekday_beforeWork() throws {
        
        // Given
        var environment = AppEnvironment.unitTest
        environment.date = { Date.weekday_0800_London }

        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700)
        
        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()
        
        // Then
        XCTAssertEqual(0, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0, meterReader.currentReading.progress)
        XCTAssertEqual(.free, meterReader.currentReading.status)
    }
    
    func testMeterReading_weekday_atWork() throws {

        // Given
        var environment = AppEnvironment.unitTest
        environment.date = { Date.weekday_1300_London }
                
        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(200, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0.5, meterReader.currentReading.progress)
        XCTAssertEqual(.atWork, meterReader.currentReading.status)
    }

    func testMeterReading_weekday_afterWork() throws {

        // Given
        var environment = AppEnvironment.unitTest
        environment.date = { Date.weekday_1900_London }
        
        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(400, meterReader.currentReading.amountEarned)
        XCTAssertEqual(1, meterReader.currentReading.progress)
        XCTAssertEqual(.free, meterReader.currentReading.status)
    }

    func testMeterReading_atWeekend_forWeekendWorker_showsReadingValue() throws {

        // Given
        var environment = AppEnvironment.unitTest
        environment.date = { Date.weekend_1300_London }
        
        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700,
                                                 rate: .init(amount: 400, type: .daily),
                                                 runAtWeekends: true)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(200, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0.5, meterReader.currentReading.progress)
        XCTAssertEqual(.atWork, meterReader.currentReading.status)
    }

    func testMeterReading_atWeekend_forNonWeekendWorker_showsZeroReading() throws {

        // Given
        var environment = AppEnvironment.unitTest
        environment.date = { Date.weekend_1300_London }
        
        let nineToFiveMeter = MeterSettings.fake(ofType: .day_worker_0900_to_1700,
                                                 runAtWeekends: false)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: nineToFiveMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(0, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0, meterReader.currentReading.progress)
        XCTAssertEqual(.free, meterReader.currentReading.status)
    }

    func testMeterReading_overnightWorker_beforeWork() throws {

        // Given
        var environment = AppEnvironment.unitTest
        environment.date = { Date.weekday_1900_London }

        let overnightMeter = MeterSettings.fake(ofType: .overnight_worker_2200_to_0600,
                                                runAtWeekends: false)


        // When
        let meterReader = MeterReader(environment: environment, meterSettings: overnightMeter)
        meterReader.start()

        // Then
        XCTAssertEqual(0, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0, meterReader.currentReading.progress)
        XCTAssertEqual(.free, meterReader.currentReading.status)
    }

    func testMeterReading_overnightWorker_atWork() throws {

        // Given
        var environment = AppEnvironment.unitTest
        environment.date = { Date.weekday_0200_London }
        
        let overnightMeter = MeterSettings.fake(ofType: .overnight_worker_2200_to_0600,
                                                runAtWeekends: false)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: overnightMeter)
        meterReader.start()
        
        // Then
        XCTAssertEqual(200, meterReader.currentReading.amountEarned)
        XCTAssertEqual(0.5, meterReader.currentReading.progress)
        XCTAssertEqual(.atWork, meterReader.currentReading.status)

    }

    func testMeterReading_overnightWorker_afterWork() throws {

        // Given
        var environment = AppEnvironment.unitTest
        environment.date = { Date.weekday_0800_London }
        
        let overnightMeter = MeterSettings.fake(ofType: .overnight_worker_2200_to_0600,
                                                runAtWeekends: false)

        // When
        let meterReader = MeterReader(environment: environment, meterSettings: overnightMeter)
        meterReader.start()
        
        // Then
        XCTAssertEqual(400, meterReader.currentReading.amountEarned)
        XCTAssertEqual(1, meterReader.currentReading.progress)
        XCTAssertEqual(.free, meterReader.currentReading.status)

    }
}

