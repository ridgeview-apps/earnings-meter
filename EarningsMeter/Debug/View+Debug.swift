import AppConfig
import DataStores
import SwiftUI

#if DEBUG

extension View {
    
    @MainActor func withStubbedEnvironment() -> some View {
        withEnvironmentValues(userPreferences: .stub())
        .environment(\.appConfig, AppConfig.stub)
    }
}

#endif
