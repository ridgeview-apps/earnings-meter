import Combine
import Foundation
import Models

public final class UserPreferencesDataStore: ObservableObject {
    
    @Published public private(set) var savedMeterSettings: MeterSettings?
    @Published public private(set) var earningsSince: Date?
    
    public var isSetUpRequired: Bool { savedMeterSettings == nil }

    public let userDefaults: UserDefaults
    
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()
    
    private  enum DataKeys: String {
        case meterSettings
        case earningsSinceDate
    }
    
    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        refresh()
    }
    
    public func save(meterSettings: MeterSettings) {
        let encodedValue = try? jsonEncoder.encode(meterSettings)
        userDefaults.set(encodedValue, forKey: DataKeys.meterSettings.rawValue)
        refresh()
    }
    
    public func save(accumulatedEarningsSince: Date) {
        let encodedValue = try? jsonEncoder.encode(accumulatedEarningsSince)
        userDefaults.set(encodedValue, forKey: DataKeys.earningsSinceDate.rawValue)
        refresh()

    }
    
    public func removeMeterSettings() {
        userDefaults.set(nil, forKey: DataKeys.meterSettings.rawValue)
        refresh()
    }
    
    public func refresh() {
        if let data = userDefaults.object(forKey: DataKeys.meterSettings.rawValue) as? Data,
           let decodedValue = try? jsonDecoder.decode(MeterSettings.self, from: data) {
            savedMeterSettings = decodedValue
        }
        
        if let data = userDefaults.object(forKey: DataKeys.earningsSinceDate.rawValue) as? Data,
           let decodedValue = try? jsonDecoder.decode(Date.self, from: data) {
            earningsSince = decodedValue
        }
    }
}

public extension UserPreferencesDataStore {
    
    static func real(sharedAppGroupName: String) -> UserPreferencesDataStore {
        let sharedUserDefaults = UserDefaults(suiteName: sharedAppGroupName)
        assert(sharedUserDefaults != nil, "Error initializing shared user defaults, using Standard defaults instead")
        return UserPreferencesDataStore(userDefaults: sharedUserDefaults ?? .standard)
    }
    
    static func stub(userDefaults: UserDefaults = .init(suiteName: UUID().uuidString) ?? .standard,
                     savedSettings: MeterSettings? = nil) -> UserPreferencesDataStore {
        let dataStore = UserPreferencesDataStore(userDefaults: userDefaults)
        if let savedSettings {
            dataStore.save(meterSettings: savedSettings)
        } else {
            dataStore.removeMeterSettings()
        }
        return dataStore
    }
}
