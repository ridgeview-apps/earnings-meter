import Foundation

public typealias EarningsMeterUITestLaunchConfiguration = UITestLaunchConfiguration<UITestScenario>

/// The state a UI test asks Earnings Meter to start with.
public struct UITestScenario: Codable, Sendable {

    /// What's saved on the device at launch.
    public enum Seed: String, Codable, Sendable {
        /// Nothing saved, so the app starts with the welcome form.
        case freshInstall
        /// A £400 daily rate from 07:00 to 15:00 on weekdays, with accumulated earnings since 1 January 2026.
        case returningUser
    }

    public var seed: Seed

    public init(seed: Seed) {
        self.seed = seed
    }
}

public extension UITestScenario {
    /// The time UI tests launch with, a weekday so the meter runs. `fastlane/Snapfile` sets the simulator's status bar
    /// to the same time.
    static let now = Date(timeIntervalSince1970: 1_781_253_660)  // Friday 12 June 2026, 09:41 in London (Apple's 9:41)

    static let timeZoneIdentifier = "Europe/London"
}
