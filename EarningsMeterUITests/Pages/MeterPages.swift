import Shared
import XCTest

/// The Earnings today tab.
struct EarningsTodayPage: Page {
    let app: XCUIApplication
    // The meter has no List or ScrollView to identify, so its header stands in
    var rootElement: XCUIElement { app.staticTexts[AccessibilityID.Meter.earningsTodayHeader] }

    /// The amount earned so far today, without its currency symbol.
    var amount: XCUIElement { app.staticTexts[AccessibilityID.Meter.amount] }

    /// Taps the settings button, which shows the meter settings.
    func tapSettingsButton() -> MeterSettingsPage {
        app.buttons[AccessibilityID.Toolbar.settingsButton].tapWhenHittable()
        return .waitingToAppear(in: app)
    }
}

/// The Accumulated earnings tab.
struct AccumulatedEarningsPage: Page {
    let app: XCUIApplication
    // The meter has no List or ScrollView to identify, so its header stands in
    var rootElement: XCUIElement { app.staticTexts[AccessibilityID.Meter.accumulatedEarningsHeader] }

    /// The amount earned since the selected date, without its currency symbol.
    var amount: XCUIElement { app.staticTexts[AccessibilityID.Meter.amount] }
}
