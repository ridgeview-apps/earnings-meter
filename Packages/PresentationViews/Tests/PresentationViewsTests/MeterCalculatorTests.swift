import XCTest
import Models
@testable import PresentationViews

class MeterCalculatorTests: XCTestCase {
    
    func testDailyReading_weekday_beforeWork() throws {
        
        // Given
        let now = DateStubs.weekday_0800_London
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700()
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)
        
        // Then
        XCTAssertEqual(0, currentReading.amountEarned)
        XCTAssertEqual(0, currentReading.progress)
        XCTAssertEqual(.beforeWork, currentReading.status)
    }
    
    func testDailyReading_weekday_atWork() throws {

        // Given
        let now = DateStubs.weekday_1300_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700()

        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        XCTAssertEqual(200, currentReading.amountEarned)
        XCTAssertEqual(0.5, currentReading.progress)
        XCTAssertEqual(.atWork(progress: 0.5), currentReading.status)
    }

    func testDailyReading_weekday_afterWork() throws {

        // Given
        let now = DateStubs.weekday_1900_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700()

        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        XCTAssertEqual(400, currentReading.amountEarned)
        XCTAssertEqual(1, currentReading.progress)
        XCTAssertEqual(.afterWork, currentReading.status)
    }

    func testDailyReading_atWeekend_forWeekendWorker_showsReadingValue() throws {

        // Given
        let now = DateStubs.weekend_1300_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700(runAtWeekends: true)

        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        XCTAssertEqual(200, currentReading.amountEarned)
        XCTAssertEqual(0.5, currentReading.progress)
        XCTAssertEqual(.atWork(progress: 0.5), currentReading.status)
    }

    func testDailyReading_atWeekend_forNonWeekendWorker_showsZeroReading() throws {

        // Given
        let now = DateStubs.weekend_1300_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700(runAtWeekends: false)

        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        XCTAssertEqual(0, currentReading.amountEarned)
        XCTAssertEqual(0, currentReading.progress)
        XCTAssertEqual(.dayOff, currentReading.status)
    }

    func testDailyReading_overnightWorker_beforeWork() throws {

        // Given
        let now = DateStubs.weekday_1900_London
        let calendar = Calendar.iso8601(in: .london)
        let overnightMeter = ModelStubs.nightTime_2200_to_0600(runAtWeekends: false)


        // When
        let calculator = MeterCalculator(meterSettings: overnightMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        XCTAssertEqual(0, currentReading.amountEarned)
        XCTAssertEqual(0, currentReading.progress)
        XCTAssertEqual(.beforeWork, currentReading.status)
    }

    func testDailyReading_overnightWorker_atWork() throws {

        // Given
        let now = DateStubs.weekday_0200_London
        let calendar = Calendar.iso8601(in: .london)
        let overnightMeter = ModelStubs.nightTime_2200_to_0600(runAtWeekends: false)

        // When
        let calculator = MeterCalculator(meterSettings: overnightMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)
        
        // Then
        XCTAssertEqual(200, currentReading.amountEarned)
        XCTAssertEqual(0.5, currentReading.progress)
        XCTAssertEqual(.atWork(progress: 0.5), currentReading.status)

    }

    func testDailyReading_overnightWorker_afterWork() throws {

        // Given
        let now = DateStubs.weekday_0800_London
        let calendar = Calendar.iso8601(in: .london)
        let overnightMeter = ModelStubs.nightTime_2200_to_0600(runAtWeekends: false)

        // When
        let calculator = MeterCalculator(meterSettings: overnightMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)
        
        // Then
        XCTAssertEqual(400, currentReading.amountEarned)
        XCTAssertEqual(1, currentReading.progress)
        XCTAssertEqual(.afterWork, currentReading.status)

    }
    
    func testAccumulatedMeterReading_dayWorker_beforeWork() throws {
        // Given
        let startDate = DateStubs.UTC(year: 2023, month: 1, day: 1)!
        let now = DateStubs.UTC(year: 2023, month: 1, day: 2, hour: 7)! // Before work
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 100, type: .daily),
                                                              runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let accumulatedReading = calculator.accumulatedReading(at: now, since: startDate)
        
        // Then
        XCTAssertEqual(100, accumulatedReading.amountEarned)
        XCTAssertEqual(0, accumulatedReading.progress)
        XCTAssertEqual(.beforeWork, accumulatedReading.status)
    }
    
    func testAccumulatedMeterReading_dayWorker_atWork() throws {
        // Given
        let startDate = DateStubs.UTC(year: 2023, month: 1, day: 1)!
        let now = DateStubs.UTC(year: 2023, month: 1, day: 2, hour: 13)! // Middle of day
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 100, type: .daily),
                                                              runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let accumulatedReading = calculator.accumulatedReading(at: now, since: startDate)
        
        // Then
        XCTAssertEqual(150, accumulatedReading.amountEarned)
        XCTAssertEqual(0.5, accumulatedReading.progress)
        XCTAssertEqual(.atWork(progress: 0.5), accumulatedReading.status)
    }
    
    func testAccumulatedMeterReading_dayWorker_afterWork() throws {
        // Given
        let startDate = DateStubs.UTC(year: 2023, month: 1, day: 1)!
        let now = DateStubs.UTC(year: 2023, month: 1, day: 2, hour: 21)! // End of day
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 100, type: .daily),
                                                              runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let accumulatedReading = calculator.accumulatedReading(at: now, since: startDate)
        
        // Then
        XCTAssertEqual(200, accumulatedReading.amountEarned)
        XCTAssertEqual(1, accumulatedReading.progress)
        XCTAssertEqual(.afterWork, accumulatedReading.status)
    }
    
    func testAccumulatedMeterReading_annualRate() throws {
        // Given
        let startDate = DateStubs.UTC(year: 2020, month: 6, day: 1)!
        let now = DateStubs.UTC(year: 2023, month: 8, day: 1)!// 3 years and 61 days later
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700(rate: .init(amount: 40_000, type: .annual),
                                                              runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let accumulatedReading = calculator.accumulatedReading(at: now, since: startDate)
        
        // Then
        XCTAssertEqual(126684.93, accumulatedReading.amountEarned, accuracy: 0.1)
        XCTAssertEqual(0, accumulatedReading.progress)
        XCTAssertEqual(.beforeWork, accumulatedReading.status)
    }
    
    func testAccumulatedMeterReading_nightWorker_beforeMidday_afterWork() throws {
        // Given
        let startDate = DateStubs.UTC(year: 2023, month: 1, day: 1)!
        let now = DateStubs.UTC(year: 2023, month: 1, day: 2, hour: 10)! // 10am (after work)
        let nineToFiveMeter = ModelStubs.nightTime_2200_to_0600(rate: .init(amount: 100, type: .daily),
                                                                runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let accumulatedReading = calculator.accumulatedReading(at: now, since: startDate)
        
        // Then
        XCTAssertEqual(100, accumulatedReading.amountEarned)
        XCTAssertEqual(1, accumulatedReading.progress)
        XCTAssertEqual(.afterWork, accumulatedReading.status)
    }
    
    func testAccumulatedMeterReading_nightWorker_afterMidday_beforeWork() throws {
        // Given
        let startDate = DateStubs.UTC(year: 2023, month: 1, day: 1)!
        let now = DateStubs.UTC(year: 2023, month: 1, day: 2, hour: 21)! // 9pm (before work)
        let nineToFiveMeter = ModelStubs.nightTime_2200_to_0600(rate: .init(amount: 100, type: .daily),
                                                                runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let accumulatedReading = calculator.accumulatedReading(at: now, since: startDate)
        
        // Then
        XCTAssertEqual(100, accumulatedReading.amountEarned)
        XCTAssertEqual(0, accumulatedReading.progress)
        XCTAssertEqual(.beforeWork, accumulatedReading.status)
    }
    
    func testAccumulatedMeterReading_nightWorker_atWork() throws {
        // Given
        let startDate = DateStubs.UTC(year: 2023, month: 1, day: 1)!
        let now = DateStubs.UTC(year: 2023, month: 1, day: 3, hour: 2)! // Middle of night (next day)
        let nineToFiveMeter = ModelStubs.nightTime_2200_to_0600(rate: .init(amount: 100, type: .daily),
                                                                runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let accumulatedReading = calculator.accumulatedReading(at: now, since: startDate)
        
        // Then
        XCTAssertEqual(150, accumulatedReading.amountEarned)
        XCTAssertEqual(0.5, accumulatedReading.progress)
        XCTAssertEqual(.atWork(progress: 0.5), accumulatedReading.status)
    }
    
    func testAccumulatedMeterReading_nightWorker_afterWork_beforeMidday() throws {
        // Given
        let startDate = DateStubs.UTC(year: 2023, month: 1, day: 1)!
        let now = DateStubs.UTC(year: 2023, month: 1, day: 3, hour: 8)! // After work (next day)
        let nineToFiveMeter = ModelStubs.nightTime_2200_to_0600(rate: .init(amount: 100, type: .daily),
                                                                runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let accumulatedReading = calculator.accumulatedReading(at: now, since: startDate)
        
        // Then
        XCTAssertEqual(200, accumulatedReading.amountEarned)
        XCTAssertEqual(1, accumulatedReading.progress)
        XCTAssertEqual(.afterWork, accumulatedReading.status)
    }
    
    func testAccumulatedMeterReading_nightWorker_beforeWork_afterMidday() throws {
        // Given
        let startDate = DateStubs.UTC(year: 2023, month: 1, day: 1)!
        let now = DateStubs.UTC(year: 2023, month: 1, day: 3, hour: 13)!
        let nineToFiveMeter = ModelStubs.nightTime_2200_to_0600(rate: .init(amount: 100, type: .daily),
                                                                runAtWeekends: true)
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let accumulatedReading = calculator.accumulatedReading(at: now, since: startDate)
        
        // Then
        XCTAssertEqual(200, accumulatedReading.amountEarned)
        XCTAssertEqual(0, accumulatedReading.progress)
        XCTAssertEqual(.beforeWork, accumulatedReading.status)
    }
    
}


extension Calendar {

    static func iso8601(in timeZone: TimeZone = .UTC) -> Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = timeZone
        return cal
    }
}
