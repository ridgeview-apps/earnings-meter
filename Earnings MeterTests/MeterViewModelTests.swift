//
//  MeterViewModelTests.swift
//  Earnings MeterTests
//
//  Created by Shilan Patel on 23/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import XCTest
import Combine
@testable import Earnings_Meter

class MeterViewModelTests: XCTestCase {
    
    private let appState = AppEnvironment.unitTest.appState
    private let userDataService = AppEnvironment.unitTest.services.userData
    private let calendar = Calendar.iso8601
    private var cancelBag = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testCurrentReading() throws {
        let fakeNow_10_00_AM = calendar.date(from: .init(year: 2020, month: 7, day: 21, hour: 10, minute: 0))!
        let fakeNow_11_00_AM = calendar.date(from: .init(year: 2020, month: 7, day: 21, hour: 11, minute: 0))!
        
        let dateGenerator = FakeDateGenerator(now: fakeNow_10_00_AM)
        
        // Given
        appState.userData.meterSettings = AppState.MeterSettings.day_worker_0900_to_1700(withDailyRate: 800,
                                                                                         calendar: calendar,
                                                                                         dateGenerator: dateGenerator)
        // When
        let meterViewModel = MeterViewModel(appState: appState,
                                            actionHandlers: .init(onTappedSettings: {}),
                                            timeFormatter: .testShortTimeStyle,
                                            calendar: calendar,
                                            dateGenerator: dateGenerator)
        
        // Then
        XCTAssertEqual("meter-background", meterViewModel.backgroundImage)
        XCTAssertEqual("meter.header.earnings.today.title", meterViewModel.headerTextKey)
        XCTAssertEqual("09:00", meterViewModel.progressBarStartTimeText)
        XCTAssertEqual("17:00", meterViewModel.progressBarEndTimeText)
        
        XCTAssertEqual(100, meterViewModel.currentReading.amountEarned)
        XCTAssertEqual(1/8, meterViewModel.currentReading.progress)
        XCTAssertEqual(.hired, meterViewModel.currentReading.status)
        
        // ... start the meter around 11am (reading should update)
        meterViewModel.inputs.appear() // Starts the meter
        dateGenerator.now = fakeNow_11_00_AM
        
        let expectedReading = expectation(description: "updatedReading")
        
        meterViewModel.$currentReading.dropFirst().sink { _ in
            expectedReading.fulfill()
        }.store(in: &cancelBag)
        
        wait(for: [expectedReading], timeout: 1.0)
        
        XCTAssertEqual(200, meterViewModel.currentReading.amountEarned)
        XCTAssertEqual(2/8, meterViewModel.currentReading.progress)
        XCTAssertEqual(.hired, meterViewModel.currentReading.status)
    }
    
    func testTapSettings() {
        let fakeNow_10_00_AM = calendar.date(from: .init(year: 2020, month: 7, day: 21, hour: 10, minute: 0))!
        let dateGenerator = FakeDateGenerator(now: fakeNow_10_00_AM)
        
        // Given
        appState.userData.meterSettings = AppState.MeterSettings.day_worker_0900_to_1700(withDailyRate: 800,
                                                                                         calendar: calendar,
                                                                                         dateGenerator: dateGenerator)
        // When
        let tappedSettingsExpectation = expectation(description: "tappedSettingsExpectation")
        let meterViewModel = MeterViewModel(appState: appState,
                                            actionHandlers: .init(onTappedSettings: {
                                                tappedSettingsExpectation.fulfill()
                                            }),
                                            timeFormatter: .testShortTimeStyle,
                                            calendar: calendar,
                                            dateGenerator: dateGenerator)
        meterViewModel.inputs.appear()
        meterViewModel.inputs.tapSettingsButton()
        
        // Then
        wait(for: [tappedSettingsExpectation], timeout: 1.0)
    }
}

