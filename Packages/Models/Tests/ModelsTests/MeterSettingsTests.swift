import XCTest

@testable import Models
@testable import ModelStubs

final class MeterSettingsTests: XCTestCase {

    func testMeterTimeSeconds() throws {
        XCTAssertEqual(25200, MeterSettings.MeterTime(hour: 7, minute: 0).seconds)
        XCTAssertEqual(68400, MeterSettings.MeterTime(hour: 19, minute: 0).seconds)
    }
    
    func testDailyRateCalulationForRateType() throws {
        // Approximate calulations for 9 to 5 day (8 hours), business days per year = 261
        let meterSettingsDailyRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 400, type: .daily))
        let meterSettingsHourlyRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 50, type: .hourly))
        let meterSettingsAnnualRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 10_4400, type: .annual))
        
        XCTAssertEqual(400, meterSettingsDailyRate.dailyRate)
        XCTAssertEqual(400, meterSettingsHourlyRate.dailyRate)
        XCTAssertEqual(400, meterSettingsAnnualRate.dailyRate)
    }
    
    func testAnnualRateCalulationForRateType() throws {
        // Approximate calulations for 9 to 5 day (8 hours), business days per year = 261
        let meterSettingsDailyRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 400, type: .daily))
        let meterSettingsHourlyRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 50, type: .hourly))
        let meterSettingsAnnualRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 104_400, type: .annual))
        
        XCTAssertEqual(104_400, meterSettingsDailyRate.annualRate)
        XCTAssertEqual(104_400, meterSettingsHourlyRate.annualRate)
        XCTAssertEqual(104_400, meterSettingsAnnualRate.annualRate)
    }
    
    func testWorkDayDurationValue() {
        let meterSettingsDailyRate = ModelStubs.dayTime_0900_to_1700()
        // 28_800 == 8 hours == (8 * 60 * 60)
        XCTAssertEqual(28_800, meterSettingsDailyRate.workDayDuration)
    }
    
    func testIsOverNightWorker() {
        let dayTimeWorker = ModelStubs.dayTime_0900_to_1700()
        let nightWorker = ModelStubs.nightTime_2200_to_0600()
        
        XCTAssertFalse(dayTimeWorker.isOvernightWorker)
        XCTAssertTrue(nightWorker.isOvernightWorker)
    }
}
