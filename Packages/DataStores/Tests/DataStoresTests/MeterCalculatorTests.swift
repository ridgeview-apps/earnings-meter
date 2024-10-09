import Foundation
import Testing
import Models
import ModelStubs
import Shared

@testable import DataStores

struct MeterCalculatorTests {
    
    @Test
    func dailyReading_weekday_beforeWork() throws {
        
        // Given
        let now = DateStubs.weekday_0800_London
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700()
        let calendar = Calendar.iso8601(in: .london)
        
        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)
        
        // Then
        #expect(currentReading.amountEarned == 0)
        #expect(currentReading.progress == 0)
        #expect(currentReading.status == .notStarted)
    }
    
    @Test
    func dailyReading_weekday_atWork() throws {

        // Given
        let now = DateStubs.weekday_1300_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700()

        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        #expect(currentReading.amountEarned == 200)
        #expect(currentReading.progress == 0.5)
        #expect(currentReading.status == .working(progress: 0.5))
    }

    @Test
    func dailyReading_weekday_afterWork() throws {

        // Given
        let now = DateStubs.weekday_1900_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700()

        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        #expect(currentReading.amountEarned == 400)
        #expect(currentReading.progress == 1)
        #expect(currentReading.status == .finished)
    }

    @Test
    func dailyReading_atWeekend_forWeekendWorker_showsReadingValue() throws {

        // Given
        let now = DateStubs.weekend_1300_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700(runAtWeekends: true)

        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        #expect(currentReading.amountEarned == 200)
        #expect(currentReading.progress == 0.5)
        #expect(currentReading.status == .working(progress: 0.5))
    }

    @Test
    func dailyReading_atWeekend_forNonWeekendWorker_showsZeroReading() throws {

        // Given
        let now = DateStubs.weekend_1300_London
        let calendar = Calendar.iso8601(in: .london)
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700(runAtWeekends: false)

        // When
        let calculator = MeterCalculator(meterSettings: nineToFiveMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        #expect(currentReading.amountEarned == 0)
        #expect(currentReading.progress == 0)
        #expect(currentReading.status == .notStarted)
    }

    @Test
    func dailyReading_overnightWorker_beforeWork() throws {

        // Given
        let now = DateStubs.weekday_1900_London
        let calendar = Calendar.iso8601(in: .london)
        let overnightMeter = ModelStubs.nightTime_2200_to_0600(runAtWeekends: false)


        // When
        let calculator = MeterCalculator(meterSettings: overnightMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)

        // Then
        #expect(currentReading.amountEarned == 0)
        #expect(currentReading.progress == 0)
        #expect(currentReading.status == .notStarted)
    }

    @Test
    func dailyReading_overnightWorker_atWork() throws {

        // Given
        let now = DateStubs.weekday_0200_London
        let calendar = Calendar.iso8601(in: .london)
        let overnightMeter = ModelStubs.nightTime_2200_to_0600(runAtWeekends: false)

        // When
        let calculator = MeterCalculator(meterSettings: overnightMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)
        
        // Then
        #expect(currentReading.amountEarned == 200)
        #expect(currentReading.progress == 0.5)
        #expect(currentReading.status == .working(progress: 0.5))
    }

    @Test
    func dailyReading_overnightWorker_afterWork() throws {

        // Given
        let now = DateStubs.weekday_0800_London
        let calendar = Calendar.iso8601(in: .london)
        let overnightMeter = ModelStubs.nightTime_2200_to_0600(runAtWeekends: false)

        // When
        let calculator = MeterCalculator(meterSettings: overnightMeter, calendar: calendar)
        let currentReading = calculator.dailyReading(at: now)
        
        // Then
        #expect(currentReading.amountEarned == 400)
        #expect(currentReading.progress == 1)
        #expect(currentReading.status == .finished)
    }
    
    @Test
    func accumulatedMeterReading_dayWorker_beforeWork() throws {
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
        #expect(accumulatedReading.amountEarned == 100)
        #expect(accumulatedReading.progress == 0)
        #expect(accumulatedReading.status == .notStarted)
    }
    
    @Test
    func accumulatedMeterReading_dayWorker_atWork() throws {
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
        #expect(accumulatedReading.amountEarned == 150)
        #expect(accumulatedReading.progress == 0.5)
        #expect(accumulatedReading.status == .working(progress: 0.5))
    }
    
    @Test
    func accumulatedMeterReading_dayWorker_afterWork() throws {
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
        #expect(accumulatedReading.amountEarned == 200)
        #expect(accumulatedReading.progress == 1)
        #expect(accumulatedReading.status == .finished)
    }
    
    @Test
    func accumulatedMeterReading_annualRate() throws {
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
        #expect(accumulatedReading.amountEarned.isApproximatelyEqual(to: 126684.93, plusOrMinus: 0.01))
        #expect(accumulatedReading.progress == 0)
        #expect(accumulatedReading.status == .notStarted)
    }
    
    @Test
    func accumulatedMeterReading_nightWorker_beforeMidday_afterWork() throws {
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
        #expect(accumulatedReading.amountEarned == 100)
        #expect(accumulatedReading.progress == 1)
        #expect(accumulatedReading.status == .finished)
    }
    
    @Test
    func accumulatedMeterReading_nightWorker_afterMidday_beforeWork() throws {
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
        #expect(accumulatedReading.amountEarned == 100)
        #expect(accumulatedReading.progress == 0)
        #expect(accumulatedReading.status == .notStarted)
    }
    
    @Test
    func accumulatedMeterReading_nightWorker_atWork() throws {
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
        #expect(accumulatedReading.amountEarned == 150)
        #expect(accumulatedReading.progress == 0.5)
        #expect(accumulatedReading.status == .working(progress: 0.5))
    }
    
    @Test
    func accumulatedMeterReading_nightWorker_afterWork_beforeMidday() throws {
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
        #expect(accumulatedReading.amountEarned == 200)
        #expect(accumulatedReading.progress == 1)
        #expect(accumulatedReading.status == .finished)
    }
    
    @Test
    func accumulatedMeterReading_nightWorker_beforeWork_afterMidday() throws {
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
        #expect(accumulatedReading.amountEarned == 200)
        #expect(accumulatedReading.progress == 0)
        #expect(accumulatedReading.status == .notStarted)
    }
    
}


extension Calendar {

    static func iso8601(in timeZone: TimeZone = .UTC) -> Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = timeZone
        return cal
    }
}
