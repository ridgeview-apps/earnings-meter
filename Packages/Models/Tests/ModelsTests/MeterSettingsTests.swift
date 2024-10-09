import Testing

@testable import Models
@testable import ModelStubs

struct MeterSettingsTests {

    @Test
    func meterTimeSeconds() throws {
        #expect(MeterSettings.MeterTime(hour: 7, minute: 0).seconds == 25200)
        #expect(MeterSettings.MeterTime(hour: 19, minute: 0).seconds == 68400)
    }
    
    @Test
    func dailyRateCalulationForRateType() throws {
        // Approximate calulations for 9 to 5 day (8 hours), business days per year = 261
        let meterSettingsDailyRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 400, type: .daily))
        let meterSettingsHourlyRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 50, type: .hourly))
        let meterSettingsAnnualRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 10_4400, type: .annual))
        
        #expect(meterSettingsDailyRate.dailyRate == 400)
        #expect(meterSettingsHourlyRate.dailyRate == 400)
        #expect(meterSettingsAnnualRate.dailyRate == 400)
    }
    
    @Test
    func annualRateCalulationForRateType() throws {
        // Approximate calulations for 9 to 5 day (8 hours), business days per year = 261
        let meterSettingsDailyRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 400, type: .daily))
        let meterSettingsHourlyRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 50, type: .hourly))
        let meterSettingsAnnualRate = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 104_400, type: .annual))
        
        #expect(meterSettingsDailyRate.annualRate == 104_400)
        #expect(meterSettingsHourlyRate.annualRate == 104_400)
        #expect(meterSettingsAnnualRate.annualRate == 104_400)
    }
    
    @Test
    func workDayDurationValue() {
        let meterSettingsDailyRate = ModelStubs.dayTime_0900_to_1700()
        // 28_800 == 8 hours == (8 * 60 * 60)
        #expect(meterSettingsDailyRate.workDayDuration == 28_800)
    }
    
    @Test
    func isOverNightWorker() {
        let dayTimeWorker = ModelStubs.dayTime_0900_to_1700()
        let nightWorker = ModelStubs.nightTime_2200_to_0600()
        
        #expect(!dayTimeWorker.isOvernightWorker)
        #expect(nightWorker.isOvernightWorker)
    }
}
