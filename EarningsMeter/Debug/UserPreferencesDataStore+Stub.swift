import DataStores
import Foundation

extension UserPreferencesDataStore {
    
    static func stub() -> UserPreferencesDataStore {
        .init(userDefaults: .init(suiteName: UUID().uuidString) ?? .standard)
    }
}
