import AppConfig
import SwiftUI

// MARK: - AppConfig environment key

private struct AppConfigEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppConfig = .real
}

extension EnvironmentValues {
    var appConfig: AppConfig {
        get { self[AppConfigEnvironmentKey.self] }
        set { self[AppConfigEnvironmentKey.self] = newValue }
    }
}
