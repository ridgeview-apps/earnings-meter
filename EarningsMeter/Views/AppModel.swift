import AppConfig
import DataStores
import Models
import Foundation

@MainActor
final class AppModel: ObservableObject {

    private(set) var userPreferences: UserPreferencesDataStore
    
    init(userPreferences: UserPreferencesDataStore) {
        self.userPreferences = userPreferences
    }
}

extension AppConfig {
    static var real: AppConfig { loadedFromInfoPlist(inBundle: .main) }
}


extension AppModel {
    static func real() -> AppModel {
        let appConfig = AppConfig.real
        return .init(userPreferences: UserPreferencesDataStore.real(sharedAppGroupName: appConfig.appGroupName))
    }
}
