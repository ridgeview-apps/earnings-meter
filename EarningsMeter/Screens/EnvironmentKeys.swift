import SwiftUI

// MARK: - AppEnvironment key

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = .shared
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
