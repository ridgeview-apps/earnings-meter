import SwiftUI

// MARK: - AppConfig key

private struct AppConfigKey: EnvironmentKey {
    static let defaultValue: AppConfig = .shared
}

extension EnvironmentValues {
    var appConfig: AppConfig {
        get { self[AppConfigKey.self] }
        set { self[AppConfigKey.self] = newValue }
    }
}
