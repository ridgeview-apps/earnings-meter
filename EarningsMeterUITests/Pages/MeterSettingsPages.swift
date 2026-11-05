import Shared
import XCTest

/// The meter settings form: the welcome form on a fresh install, otherwise the edit form.
struct MeterSettingsPage: Page {
    let app: XCUIApplication
    var rootElement: XCUIElement { app.collectionViews[AccessibilityID.MeterSettings.list] }

    var rateField: XCUIElement { app.textFields[AccessibilityID.MeterSettings.rateField] }
    /// Start on the welcome form, Save on the edit form.
    var saveButton: XCUIElement { app.buttons[AccessibilityID.MeterSettings.saveButton] }

    /// Taps the rate field and replaces its text with `rate`.
    func typeRate(_ rate: String) -> MeterSettingsPage {
        rateField.tapWhenHittable()
        // An empty field's value is its placeholder, so this can delete more than it needs to, which is harmless
        let existingText = rateField.value as? String ?? ""
        let deletes = String(repeating: XCUIKeyboardKey.delete.rawValue, count: existingText.count)
        rateField.typeText(deletes + rate)
        return self
    }

    /// Taps Start or Save, which saves the settings and closes the form. Tests only open the form from the Earnings
    /// today tab, so that's where it leads.
    func tapSaveButton() -> EarningsTodayPage {
        saveButton.tapWhenHittable()
        rootElement.waitToDisappear()
        return .waitingToAppear(in: app)
    }

    /// Taps the close button with unsaved changes, which asks whether to discard them.
    func tapCloseButton() -> DiscardChangesDialogPage {
        app.buttons[AccessibilityID.Toolbar.closeButton].tapWhenHittable()
        return .waitingToAppear(in: app)
    }
}

/// The dialog asking whether to discard unsaved meter settings.
struct DiscardChangesDialogPage: Page {
    let app: XCUIApplication
    var rootElement: XCUIElement { discardButton }

    // SwiftUI gives the dialog's button and the button inside it the same identifier
    private var discardButton: XCUIElement {
        app.buttons[AccessibilityID.MeterSettings.discardChangesButton].firstMatch
    }

    /// Taps Discard, which closes the form without saving. Tests only open the form from the Earnings today tab, so
    /// that's where it leads.
    func tapDiscardButton() -> EarningsTodayPage {
        discardButton.tapWhenHittable()
        app.collectionViews[AccessibilityID.MeterSettings.list].waitToDisappear()
        return .waitingToAppear(in: app)
    }

    /// Taps outside the dialog, which goes back to the form with the changes still in it.
    func tapOutside() -> MeterSettingsPage {
        // The dialog is a popover without a cancel button (seen on iOS 27). The system's dismiss region around it has no
        // AccessibilityID, but it does have this identifier
        app.otherElements["PopoverDismissRegion"].tapWhenHittable()
        discardButton.waitToDisappear()
        return .waitingToAppear(in: app)
    }
}
