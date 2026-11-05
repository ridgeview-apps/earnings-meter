import Shared
import XCTest

/// The App Store screenshots, captured by `fastlane snapshot`.
final class ScreenshotTests: ScreenshotTestCase {

    private func configuration(seed: UITestScenario.Seed) -> EarningsMeterUITestLaunchConfiguration {
        EarningsMeterUITestLaunchConfiguration(
            now: UITestScenario.now,
            timeZoneIdentifier: UITestScenario.timeZoneIdentifier,
            disablesAnimations: true,
            scenario: UITestScenario(seed: seed)
        )
    }

    @MainActor
    func testAppStoreScreenshots() throws {
        XCUIDevice.shared.orientation = UIDevice.current.userInterfaceIdiom == .pad ? .landscapeLeft : .portrait

        let freshInstall = try launchApp(with: configuration(seed: .freshInstall))
        capture(MeterSettingsPage.waitingToAppear(in: freshInstall), as: "Setup")

        // A returning user rather than saving the form above, so the meter shows a day under way and months of
        // accumulated earnings
        let app = try launchApp(with: configuration(seed: .returningUser))
        let earningsToday = EarningsTodayPage.waitingToAppear(in: app)
        capture(earningsToday, as: "DailyEarnings")

        let accumulatedEarnings = earningsToday.tabBar.tapAccumulatedEarningsTab()
        capture(accumulatedEarnings, as: "AccumulatedEarnings")
    }
}
