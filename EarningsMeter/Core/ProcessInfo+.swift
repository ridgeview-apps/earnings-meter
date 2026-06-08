import Foundation

extension ProcessInfo {
    static var isRunningUITests: Bool {
        processInfo.arguments.contains("-ui-tests")
    }

    static var animationsEnabled: Bool { !animationsDisabled }

    static var animationsDisabled: Bool {
        processInfo.arguments.contains("-disable-animations")
    }

    static var resetUserPreferences: Bool {
        processInfo.arguments.contains("-reset-user-preferences")
    }
}
