import XCTest
import Models
import ModelStubs

@testable import PresentationViews

class MeterSettingsInputFormTests: XCTestCase {
    
    // N.B. these are just basic tests based on the input amount (can flesh these out further later).
    
    func testInputForm_welcomeMode() {
        // Given
        let form = MeterSettingsInputForm.welcomeMode()
        
        // When
        let rateAmountTextField = form.rateAmountFieldText
        
        // Then
        XCTAssertTrue(rateAmountTextField.isEmpty)
        XCTAssertFalse(form.isValid)
    }
    
    func testInputForm_updateMode() {
        // Given
        let form = MeterSettingsInputForm.updateMode(with: ModelStubs.dayTime_0900_to_1700())
        
        // When
        let rateAmountTextField = form.rateAmountFieldText
        
        // Then
        XCTAssertTrue(!rateAmountTextField.isEmpty)
    }
    
    
    func testInputForm_becomesValid_whenNumericAmountIsEntered() {
        // Given
        var form = MeterSettingsInputForm.welcomeMode()
        let isInitiallyValid = form.isValid
        
        // When
        form.rateAmountFieldText = "400"
        let isNowValid = form.isValid
        
        // Then
        XCTAssertFalse(isInitiallyValid)
        XCTAssertTrue(isNowValid)
    }
    
    func testInputForm_remainsInvalid_whenNonNumericAmountIsEntered() {
        // Given
        var form = MeterSettingsInputForm.welcomeMode()
        let isInitiallyValid = form.isValid
        
        // When
        form.rateAmountFieldText = "NON_NUMERIC_AMOUNT"
        let isNowValid = form.isValid
        
        // Then
        XCTAssertFalse(isInitiallyValid)
        XCTAssertFalse(isNowValid)
    }
}
