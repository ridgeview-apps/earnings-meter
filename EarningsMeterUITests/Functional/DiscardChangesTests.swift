import Shared
import XCTest

/// Closing the meter settings with unsaved changes. The returning user's rate is £400 a day, 07:00 to 15:00.
final class DiscardChangesTests: UITestCase {

    private var configuration: EarningsMeterUITestLaunchConfiguration {
        EarningsMeterUITestLaunchConfiguration(
            now: UITestScenario.now,
            timeZoneIdentifier: UITestScenario.timeZoneIdentifier,
            disablesAnimations: true,
            scenario: UITestScenario(seed: .returningUser)
        )
    }

    @MainActor
    func testTappingOutsideTheDialogKeepsTheChanges() throws {
        let app = try launchApp(with: configuration)
        let settings =
            EarningsTodayPage.waitingToAppear(in: app)
            .tapSettingsButton()
            .typeRate("500")
            .tapCloseButton()
            .tapOutside()

        XCTAssertEqual(settings.rateField.value as? String, "500")
    }

    @MainActor
    func testDiscardingKeepsTheSavedSettings() throws {
        let app = try launchApp(with: configuration)
        let earningsToday =
            EarningsTodayPage.waitingToAppear(in: app)
            .tapSettingsButton()
            .typeRate("500")
            .tapCloseButton()
            .tapDiscardButton()

        // By 09:41 a £400 day from 07:00 to 15:00 is 161 of its 480 minutes in
        XCTAssertEqual(earningsToday.amount.label, "134.17")
        XCTAssertEqual(earningsToday.tapSettingsButton().rateField.value as? String, "400.00")
    }
}
