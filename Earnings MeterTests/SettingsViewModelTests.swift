//
//  SettingsViewModelTests.swift
//  Earnings MeterTests
//
//  Created by Shilan Patel on 20/07/2020.
//  Copyright © 2020 Shilan Patel. All rights reserved.
//

import XCTest
@testable import Earnings_Meter

class SettingsViewModelTests: XCTestCase {
    
    private let appState = AppEnvironment.unitTest.appState
    private let userDataService = AppEnvironment.unitTest.services.userData
    private let calendar = Calendar.iso8601
    
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testWelcomeState() throws {
        // Given
        appState.userData.meterSettings = nil
        let fakeNow = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        
        // When
        let settingsViewModel = SettingsViewModel(appState: appState,
                                                  userDataService: userDataService,
                                                  actionHandlers: .init(onSave: {}),
                                                  calendar: calendar,
                                                  dateGenerator: FakeDateGenerator(now: fakeNow))
        
        let expectedStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: fakeNow)!
        let expectedEndTime = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: fakeNow)!
        
        // Then
        XCTAssertFalse(settingsViewModel.isStartPickerExpanded)
        XCTAssertFalse(settingsViewModel.isEndPickerExpanded)

        XCTAssertEqual(0, settingsViewModel.formInput.dailyRate)
        XCTAssertEqual("", settingsViewModel.formInput.rateText)
        XCTAssertEqual("settings.workingHours.startTime.title", settingsViewModel.startPickerTitle)
        XCTAssertEqual("settings.workingHours.endTime.title", settingsViewModel.endPickerTitle)
        XCTAssertEqual(expectedStartTime, settingsViewModel.formInput.startTime)
        XCTAssertEqual(expectedEndTime, settingsViewModel.formInput.endTime)
        XCTAssertFalse(settingsViewModel.formInput.isValid)

        XCTAssertEqual("settings.workingHours.startTime.title", settingsViewModel.startPickerTitle)
        XCTAssertEqual("settings.workingHours.endTime.title", settingsViewModel.endPickerTitle)
        XCTAssertEqual("settings.rate.title", settingsViewModel.rateTitleText)
        XCTAssertEqual("settings.rate.placeholder", settingsViewModel.ratePlaceholderText)
        XCTAssertEqual("settings.runAtWeekends.title", settingsViewModel.runAtWeekendsTitleText)
        XCTAssertEqual("settings.welcome.message", settingsViewModel.welcomeMessageTitle)
        XCTAssertEqual("settings.navigation.title.welcome", settingsViewModel.navigationBarTitle)
        XCTAssertEqual("settings.footer.button.title.start", settingsViewModel.saveButtonText)
        XCTAssertEqual(.welcome, settingsViewModel.viewState)
        
        XCTAssertFalse(settingsViewModel.isSaveButtonEnabled)
        XCTAssertNil(settingsViewModel.firstResponderId)
    }
    
    func testEditState() throws {
        // Given
        let fakeNow = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        let dateGenerator = FakeDateGenerator(now: fakeNow)
        
        // When
        appState.userData.meterSettings = AppState.MeterSettings.day_worker_0900_to_1700(withDailyRate: 400,
                                                                                         calendar: calendar,
                                                                                         dateGenerator: dateGenerator)
    
        let settingsViewModel = SettingsViewModel(appState: appState,
                                                  userDataService: userDataService,
                                                  actionHandlers: .init(onSave: {}),
                                                  calendar: calendar,
                                                  dateGenerator: FakeDateGenerator(now: fakeNow))
        
        let expectedStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: fakeNow)!
        let expectedEndTime = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: fakeNow)!
        
        XCTAssertFalse(settingsViewModel.isStartPickerExpanded)
        XCTAssertFalse(settingsViewModel.isEndPickerExpanded)

        XCTAssertEqual(400, settingsViewModel.formInput.dailyRate)
        XCTAssertEqual("400.00", settingsViewModel.formInput.rateText)
        XCTAssertEqual("settings.workingHours.startTime.title", settingsViewModel.startPickerTitle)
        XCTAssertEqual("settings.workingHours.endTime.title", settingsViewModel.endPickerTitle)
        XCTAssertEqual(expectedStartTime, settingsViewModel.formInput.startTime)
        XCTAssertEqual(expectedEndTime, settingsViewModel.formInput.endTime)
        XCTAssertTrue(settingsViewModel.formInput.isValid)

        XCTAssertEqual("settings.workingHours.startTime.title", settingsViewModel.startPickerTitle)
        XCTAssertEqual("settings.workingHours.endTime.title", settingsViewModel.endPickerTitle)
        XCTAssertEqual("settings.rate.title", settingsViewModel.rateTitleText)
        XCTAssertEqual("settings.rate.placeholder", settingsViewModel.ratePlaceholderText)
        XCTAssertEqual("settings.runAtWeekends.title", settingsViewModel.runAtWeekendsTitleText)
        XCTAssertEqual("settings.navigation.title.edit", settingsViewModel.navigationBarTitle)
        XCTAssertEqual("settings.footer.button.title.save", settingsViewModel.saveButtonText)
        XCTAssertEqual(.edit, settingsViewModel.viewState)
        
        XCTAssertTrue(settingsViewModel.isSaveButtonEnabled)
        XCTAssertNil(settingsViewModel.firstResponderId)
    }
    
    func testFormInputValidation() {
        // Given
        appState.userData.meterSettings = nil
        let fakeNow = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        
        // When
        let settingsViewModel = SettingsViewModel(appState: appState,
                                                  userDataService: userDataService,
                                                  actionHandlers: .init(onSave: {}),
                                                  calendar: calendar,
                                                  dateGenerator: FakeDateGenerator(now: fakeNow))
        
        // Then
        // 1. Form input initially valid
        XCTAssertFalse(settingsViewModel.formInput.isValid)
        XCTAssertFalse(settingsViewModel.isSaveButtonEnabled)
        
        // 2. Populate rate (invalid value) - input still invalid
        settingsViewModel.formInput.rateText = "ABC"
        XCTAssertFalse(settingsViewModel.formInput.isValid)
        
        // 3. Populate rate (valid value) - input now value
        settingsViewModel.formInput.rateText = "123"
        XCTAssertTrue(settingsViewModel.formInput.isValid)
        XCTAssertTrue(settingsViewModel.isSaveButtonEnabled)
    }
    
    func testTappingTheRateTextField() {
        // Given
        appState.userData.meterSettings = nil
        let fakeNow = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        
        // When
        let settingsViewModel = SettingsViewModel(appState: appState,
                                                  userDataService: userDataService,
                                                  actionHandlers: .init(onSave: {}),
                                                  calendar: calendar,
                                                  dateGenerator: FakeDateGenerator(now: fakeNow))
        settingsViewModel.inputs.tapped(textFieldId: .dailyRate)
        
        // Then
        XCTAssertEqual(.dailyRate, settingsViewModel.firstResponderId)
        
        settingsViewModel.inputs.didSetFirstResponder()
        XCTAssertNil(settingsViewModel.firstResponderId)
    }
    
    func testSave() {
        // Given
        appState.userData.meterSettings = nil
        let fakeNow = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        
        let onSaveExpectation = expectation(description: "Save callback executed")
        
        // When
        let settingsViewModel = SettingsViewModel(appState: appState,
                                                  userDataService: userDataService,
                                                  actionHandlers: .init(onSave: {
                                                    onSaveExpectation.fulfill()
                                                  }),
                                                  calendar: calendar,
                                                  dateGenerator: FakeDateGenerator(now: fakeNow))
        
        settingsViewModel.formInput.rateText = "456"
        settingsViewModel.inputs.save()
        
        // Then
        wait(for: [onSaveExpectation], timeout: 1.0)
    }
    
    func testExpandingDatePickers() {
        // Given
        appState.userData.meterSettings = nil
        let fakeNow = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        
        // When
        let settingsViewModel = SettingsViewModel(appState: appState,
                                                  userDataService: userDataService,
                                                  actionHandlers: .init(onSave: {}),
                                                  calendar: calendar,
                                                  dateGenerator: FakeDateGenerator(now: fakeNow))
        
        // Then
        
        // 1. Both date pickers initially collapsed
        XCTAssertFalse(settingsViewModel.isStartPickerExpanded)
        XCTAssertFalse(settingsViewModel.isEndPickerExpanded)
        
        // 2. Expand the start picker (start = expanded, end = collapsed)
        settingsViewModel.isStartPickerExpanded = true
        XCTAssertTrue(settingsViewModel.isStartPickerExpanded)
        XCTAssertFalse(settingsViewModel.isEndPickerExpanded)
        
        // 3. Expand the end picker (start = collapsed, end = expanded)
        settingsViewModel.isEndPickerExpanded = true
        XCTAssertFalse(settingsViewModel.isStartPickerExpanded)
        XCTAssertTrue(settingsViewModel.isEndPickerExpanded)
        
        // 3. Expand the start picker again (start = collapsed, end = expanded)
        settingsViewModel.isStartPickerExpanded = true
        XCTAssertTrue(settingsViewModel.isStartPickerExpanded)
        XCTAssertFalse(settingsViewModel.isEndPickerExpanded)
    }
}
