import XCTest
import Combine
@testable import Earnings_Meter

class SettingsViewModelTests: XCTestCase {
    
    private var cancelBag = Set<AnyCancellable>()
    
    func testWelcomeState() throws {
        // Given
        let calendar = Calendar.iso8601(in: .london)
        let fakeNow: Date = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        var environment = AppEnvironment.unitTest
        environment.date = { fakeNow }
        
        let appViewModel = AppViewModel(meterSettings: nil,
                                        environment: environment)
        
        // When
        let settingsViewModel = MeterSettingsViewModel(appViewModel: appViewModel)
        
        let expectedStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: fakeNow)!
        let expectedEndTime = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: fakeNow)!
        
        // Then
        XCTAssertFalse(settingsViewModel.isStartPickerExpanded)
        XCTAssertFalse(settingsViewModel.isEndPickerExpanded)

        XCTAssertEqual(0, settingsViewModel.formData.rateAmount)
        XCTAssertEqual("", settingsViewModel.formData.rateText)
        XCTAssertEqual("settings.workingHours.startTime.title", settingsViewModel.startPickerTitle)
        XCTAssertEqual("settings.workingHours.endTime.title", settingsViewModel.endPickerTitle)
        XCTAssertEqual(expectedStartTime, settingsViewModel.formData.startTime)
        XCTAssertEqual(expectedEndTime, settingsViewModel.formData.endTime)

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
        let calendar = Calendar.iso8601(in: .london)
        let fakeNow: Date = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        var environment = AppEnvironment.unitTest
        environment.date = { fakeNow }

        // When
        let appViewModel = AppViewModel(meterSettings: .day_worker_0900_to_1700(withDailyRate: 400),
                                        environment: environment)

        let settingsViewModel = MeterSettingsViewModel(appViewModel: appViewModel)

        let expectedStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: fakeNow)!
        let expectedEndTime = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: fakeNow)!

        XCTAssertFalse(settingsViewModel.isStartPickerExpanded)
        XCTAssertFalse(settingsViewModel.isEndPickerExpanded)

        XCTAssertEqual(400, settingsViewModel.formData.rateAmount)
        XCTAssertEqual("400.00", settingsViewModel.formData.rateText)
        XCTAssertEqual("settings.workingHours.startTime.title", settingsViewModel.startPickerTitle)
        XCTAssertEqual("settings.workingHours.endTime.title", settingsViewModel.endPickerTitle)
        XCTAssertEqual(expectedStartTime, settingsViewModel.formData.startTime)
        XCTAssertEqual(expectedEndTime, settingsViewModel.formData.endTime)

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
        let calendar = Calendar.iso8601(in: .london)
        let fakeNow: Date = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        var environment = AppEnvironment.unitTest
        environment.date = { fakeNow }
        environment.currentCalendar = { calendar }

        let appViewModel = AppViewModel(meterSettings: nil,
                                        environment: environment)
        
        // When
        let settingsViewModel = MeterSettingsViewModel(appViewModel: appViewModel)

        // Then
        // 1. Form input initially valid
        XCTAssertFalse(settingsViewModel.isSaveButtonEnabled)

        // 2. Populate rate (invalid value) - input still invalid
        settingsViewModel.formData.rateText = "ABC"
        XCTAssertFalse(settingsViewModel.isSaveButtonEnabled)

        // 3. Populate rate (valid value) - input now value
        settingsViewModel.formData.rateAmount = 1234
        XCTAssertTrue(settingsViewModel.isSaveButtonEnabled)
    }

    func testTappingTheRateTextField() {
        // Given
        let calendar = Calendar.iso8601(in: .london)
        let fakeNow: Date = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        var environment = AppEnvironment.unitTest
        environment.date = { fakeNow }
        environment.currentCalendar = { calendar }
        
        let appViewModel = AppViewModel(meterSettings: .fake(ofType: .weekdayOnlyMeter),
                                        environment: environment)

        // When
        let settingsViewModel = MeterSettingsViewModel(appViewModel: appViewModel)
        settingsViewModel.inputs.tappedTextField.send(.dailyRate)
        
        // Then
        XCTAssertEqual(.dailyRate, settingsViewModel.firstResponderId)

        settingsViewModel.inputs.didSetFirstResponder.send()
        XCTAssertNil(settingsViewModel.firstResponderId)
    }

    func testSave() {
        
        // Given
        let calendar = Calendar.iso8601(in: .london)
        let fakeNow: Date = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        var environment = AppEnvironment.unitTest
        environment.date = { fakeNow }
        environment.currentCalendar = { calendar }
        
        let appViewModel = AppViewModel(meterSettings: .fake(ofType: .weekdayOnlyMeter),
                                        environment: environment)
        
        let saveOutputAction = expectation(description: "saveOutputAction")

        // When
        let settingsViewModel = MeterSettingsViewModel(appViewModel: appViewModel)
        
        settingsViewModel
            .outputActions
            .didSave
            .sink { _ in saveOutputAction.fulfill() }
            .store(in: &cancelBag)
        
        settingsViewModel.formData.rateText = "456"
        settingsViewModel.inputs.save.send()
 
        // Then
        wait(for: [saveOutputAction], timeout: 1.0)
    }

    func testExpandingDatePickers() {
        // Given
        let calendar = Calendar.iso8601(in: .london)
        let fakeNow: Date = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        var environment = AppEnvironment.unitTest
        environment.date = { fakeNow }
        environment.currentCalendar = { calendar }
        
        let appViewModel = AppViewModel(meterSettings: nil,
                                        environment: environment)


        // When
        let settingsViewModel = MeterSettingsViewModel(appViewModel: appViewModel)

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
