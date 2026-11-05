import Shared
import XCTest

/// Setting up the meter on a fresh install. The clock is fixed at 09:41, so the meter's amount is exact.
final class OnboardingTests: UITestCase {

    private var configuration: EarningsMeterUITestLaunchConfiguration {
        EarningsMeterUITestLaunchConfiguration(
            now: UITestScenario.now,
            timeZoneIdentifier: UITestScenario.timeZoneIdentifier,
            disablesAnimations: true,
            scenario: UITestScenario(seed: .freshInstall)
        )
    }

    @MainActor
    func testEnteringARateAndStartingRunsTheMeter() throws {
        let app = try launchApp(with: configuration)
        let welcome = MeterSettingsPage.waitingToAppear(in: app)
        XCTAssertFalse(welcome.saveButton.isEnabled, "Start should be disabled until there's a rate")

        let withRate = welcome.typeRate("400")
        XCTAssertTrue(
            withRate.saveButton.wait(for: \.isEnabled, toEqual: true, timeout: XCUIElement.defaultTimeout),
            "Start should be enabled once there's a rate"
        )

        let earningsToday = withRate.tapSaveButton()
        // The welcome form's hours are 09:00 to 17:30, so by 09:41 a £400 day is 41 of its 510 minutes in
        XCTAssertEqual(earningsToday.amount.label, "32.16")
    }
}
