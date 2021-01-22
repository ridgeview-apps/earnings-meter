import XCTest
import Combine
@testable import Earnings_Meter

class MeterViewModelTests: XCTestCase {
    
    private var cancelBag = Set<AnyCancellable>()
    
    func testCurrentReading() throws {
        let calendar = Calendar.iso8601(in: .london)
        let fakeNow_10_00_AM = calendar.date(from: .init(year: 2020, month: 7, day: 21, hour: 10, minute: 0))!
        let fakeNow_11_00_AM = calendar.date(from: .init(year: 2020, month: 7, day: 21, hour: 11, minute: 0))!
        
        var fakeTimeNow = fakeNow_10_00_AM
        
        var environment = AppEnvironment.unitTest
        environment.date = { fakeTimeNow }
        environment.currentCalendar = { calendar }
        environment.formatters.dateStyles.shortTime = .testShortTimeStyle
        
        // Given
        let appViewModel = AppViewModel(meterSettings: .fake(ofType: .day_worker_0900_to_1700),
                                        environment: environment)
        
        
        // When
        let meterViewModel = MeterViewModel(appViewModel: appViewModel)
        
        // Then
        XCTAssertEqual("meter-background", meterViewModel.backgroundImage)
        XCTAssertEqual("meter.header.earnings.today.title", meterViewModel.headerTextKey)
        XCTAssertEqual("09:00", meterViewModel.progressBarStartTimeText)
        XCTAssertEqual("17:00", meterViewModel.progressBarEndTimeText)
        
        XCTAssertEqual(100, meterViewModel.currentReading.amountEarned)
        XCTAssertEqual(1/8, meterViewModel.currentReading.progress)
        XCTAssertEqual(.working, meterViewModel.currentReading.status)
        
        // ... start the meter around 11am (reading should update)
        meterViewModel.inputs.appear.send() // Starts the meter
        fakeTimeNow = fakeNow_11_00_AM
        
        let expectedReading = expectation(description: "updatedReading")
        
        meterViewModel.$currentReading.dropFirst()
            .sink { _ in expectedReading.fulfill() }
            .store(in: &cancelBag)
        
        wait(for: [expectedReading], timeout: 1.0)
        
        XCTAssertEqual(200, meterViewModel.currentReading.amountEarned)
        XCTAssertEqual(2/8, meterViewModel.currentReading.progress)
        XCTAssertEqual(.working, meterViewModel.currentReading.status)
    }
    
    func testTapSettings() {
        let calendar = Calendar.iso8601
        let fakeNow_10_00_AM = calendar.date(from: .init(year: 2020, month: 7, day: 21, hour: 10, minute: 0))!
        
        let fakeTimeNow = fakeNow_10_00_AM
        
        var environment = AppEnvironment.unitTest
        environment.date = { fakeTimeNow }
        environment.currentCalendar = { calendar }
        environment.formatters.dateStyles.shortTime = .testShortTimeStyle
        
        // Given
        let appViewModel = AppViewModel(meterSettings: .fake(ofType: .day_worker_0900_to_1700),
                                        environment: environment)
                
        // When
        let tappedSettingsOutputAction = expectation(description: "tappedSettingsOutputAction")
        let meterViewModel = MeterViewModel(appViewModel: appViewModel)
        meterViewModel
            .outputActions
            .didTapSettings
            .sink { _ in tappedSettingsOutputAction.fulfill() }
            .store(in: &cancelBag)

        
        meterViewModel.inputs.appear.send()
        meterViewModel.inputs.tapSettingsButton.send()

        // Then
        wait(for: [tappedSettingsOutputAction], timeout: 1.0)
    }
}

