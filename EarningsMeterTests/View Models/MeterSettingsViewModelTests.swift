import XCTest
import Combine
@testable import Earnings_Meter

class MeterSettingsViewModelTests: XCTestCase {
    
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
        let settingsViewModel = MeterSettingsViewModel()
        settingsViewModel.inputs.environmentObjects.send(appViewModel)

        
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
        let appViewModel = AppViewModel(meterSettings: .fake(ofType: .day_worker_0900_to_1700),
                                        environment: environment)

        let settingsViewModel = MeterSettingsViewModel()
        settingsViewModel.inputs.environmentObjects.send(appViewModel)

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
        let settingsViewModel = MeterSettingsViewModel()
        settingsViewModel.inputs.environmentObjects.send(appViewModel)

        // Then
        // 1. Form input initially valid (save button DISABLED)
        XCTAssertFalse(settingsViewModel.isSaveButtonEnabled)
        
        // 2. Populate valid rate (save button ENABLED)
        let updatedForm = settingsViewModel.formData
        updatedForm.rateText = "1234"
        settingsViewModel.formData = updatedForm
        XCTAssertTrue(settingsViewModel.isSaveButtonEnabled)


        // 3. Populate invalid rate (save button DISABLED)
        updatedForm.rateText = "ABC"
        settingsViewModel.formData = updatedForm
        XCTAssertFalse(settingsViewModel.isSaveButtonEnabled)
    }

    func testTappingTheRateTextField() {
        // Given
        let calendar = Calendar.iso8601(in: .london)
        let fakeNow: Date = calendar.date(from: .init(year: 2020, month: 7, day: 21))!
        var environment = AppEnvironment.unitTest
        environment.date = { fakeNow }
        environment.currentCalendar = { calendar }
        
        let appViewModel = AppViewModel(meterSettings: .fake(ofType: .day_worker_0900_to_1700),
                                        environment: environment)

        // When
        let settingsViewModel = MeterSettingsViewModel()
        settingsViewModel.inputs.environmentObjects.send(appViewModel)
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
        
        let appViewModel = AppViewModel(meterSettings: .fake(ofType: .day_worker_0900_to_1700),
                                        environment: environment)
        
        let saveOutputAction = expectation(description: "saveOutputAction")

        // When
        let settingsViewModel = MeterSettingsViewModel()
        settingsViewModel
            .outputActions
            .didSave
            .sink { _ in saveOutputAction.fulfill() }
            .store(in: &cancelBag)
        
        settingsViewModel.inputs.environmentObjects.send(appViewModel)
        
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
        let settingsViewModel = MeterSettingsViewModel()
        settingsViewModel.inputs.environmentObjects.send(appViewModel)

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

extension Calendar {

    static func iso8601(in timeZone: TimeZone = .UTC) -> Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = timeZone
        return cal
    }
}
