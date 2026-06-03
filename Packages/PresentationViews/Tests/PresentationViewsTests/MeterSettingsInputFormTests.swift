import Testing
import Models
import ModelStubs

@testable import PresentationViews

struct MeterSettingsInputFormTests {
    
    // N.B. these are just basic tests based on the input amount (can flesh these out further later).
    
    @Test
    func inputForm_welcomeMode() {
        // Given
        let form = MeterSettingsInputForm.welcomeMode()
        
        // When
        let rateAmountTextField = form.rateAmountFieldText
        
        // Then
        #expect(rateAmountTextField.isEmpty)
        #expect(form.emojisEnabled)
        #expect(!form.isValid)
    }
    
    @Test
    func inputForm_updateMode() {
        // Given
        let form = MeterSettingsInputForm.updateMode(with: ModelStubs.dayTime_0900_to_1700())
        
        // When
        let rateAmountTextField = form.rateAmountFieldText
        
        // Then
        #expect(!rateAmountTextField.isEmpty)
    }
    
    @Test
    func inputForm_becomesValid_whenNumericAmountIsEntered() {
        // Given
        var form = MeterSettingsInputForm.welcomeMode()
        let isInitiallyValid = form.isValid
        
        // When
        form.rateAmountFieldText = "400"
        let isNowValid = form.isValid
        
        // Then
        #expect(!isInitiallyValid)
        #expect(isNowValid)
    }
    
    @Test
    func inputForm_remainsInvalid_whenNonNumericAmountIsEntered() {
        // Given
        var form = MeterSettingsInputForm.welcomeMode()
        let isInitiallyValid = form.isValid
        
        // When
        form.rateAmountFieldText = "NON_NUMERIC_AMOUNT"
        let isNowValid = form.isValid
        
        // Then
        #expect(!isInitiallyValid)
        #expect(!isNowValid)
    }

    @Test
    func inputForm_remainsInvalid_whenStartAndEndTimesAreTheSame() {
        // Given
        var form = MeterSettingsInputForm.welcomeMode()
        form.rateAmountFieldText = "400"

        // When
        form.endTime = form.startTime

        // Then
        #expect(!form.hasValidWorkingHours)
        #expect(!form.isValid)
    }

    @Test
    func inputForm_allowsOvernightShift_whenEndTimeIsBeforeStartTime() throws {
        // Given
        var form = MeterSettingsInputForm.welcomeMode()
        form.rateAmountFieldText = "400"

        // When
        let overnightStart = form.calendar.date(bySettingHour: 22,
                                                minute: 0,
                                                second: 0,
                                                of: form.startTime)
        let overnightEnd = form.calendar.date(bySettingHour: 6,
                                              minute: 0,
                                              second: 0,
                                              of: form.endTime)
        form.startTime = try #require(overnightStart)
        form.endTime = try #require(overnightEnd)

        // Then
        #expect(form.hasOvernightWorkingHours)
        #expect(form.hasValidWorkingHours)
        #expect(form.isValid)
    }
}
