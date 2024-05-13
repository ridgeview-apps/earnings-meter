import Foundation
import Models

public extension UserDefaults {
    
    enum Keys: String {
        case userPreferences
    }
    
    // N.B. @AppStorage property wrapper is available from SwiftUI views and should be used whenever possible.
    // This property is merely exposed for other scenarios where @AppStorage is more difficult to work with (e.g. widget timelines, SwiftUI Previews)
    
    var userPreferences: UserPreferences? {
        get {
            guard let encodedRawValue = string(forKey: Keys.userPreferences.rawValue),
                  let decodedValue = UserPreferences(rawValue: encodedRawValue) else {
                return nil
            }
            return decodedValue
        }
        set {
            set(newValue?.rawValue, forKey: Keys.userPreferences.rawValue)
        }
    }
}

public extension UserDefaults {
    
    func migrateLegacyValuesIfNeeded() {
        guard string(forKey: UserDefaults.Keys.userPreferences.rawValue) == nil else {
            return
        }
        
        var legacyMeterSettings: MeterSettings?
        if let data = object(forKey: "meterSettings") as? Data,
           let decodedValue = try? JSONDecoder().decode(MeterSettings.self, from: data) {
            legacyMeterSettings = decodedValue
        }
        
        var legacyEarningsSinceDate: Date?
        if let data = object(forKey: "earningsSinceDate") as? Data,
           let decodedValue = try? JSONDecoder().decode(Date.self, from: data) {
            legacyEarningsSinceDate = decodedValue
        }
        
        let migratedPreferences = UserPreferences(meterSettings: legacyMeterSettings,
                                                  earningsSinceDate: legacyEarningsSinceDate)
        
        if let encoded = try? JSONEncoder().encode(migratedPreferences),
           let string = String(data: encoded, encoding: .utf8) {
            print("Migrating legacy user values defaults to UserPreferences")
            setValue(string, forKey: UserDefaults.Keys.userPreferences.rawValue)
        }
    }
}
