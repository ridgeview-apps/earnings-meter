import Combine
import Foundation
import Model

public final class MeterSettingsDataSource: ObservableObject {
    
    @Published public private(set) var meterSettings: MeterSettings?

    let sharedDataStore: KeyValueStore
    let standardDataStore: KeyValueStore
    
    init(sharedDataStore: KeyValueStore,
         standardDataStore: KeyValueStore) {
        self.sharedDataStore = sharedDataStore
        self.standardDataStore = standardDataStore
    }
    
    public func load() {
        migrateMeterSettingsIfNeeded()
        self.meterSettings = sharedDataStore.meterSettings
    }
    
    public func save(meterSettings: MeterSettings?) {
        sharedDataStore.set(meterSettings: meterSettings)
        load()
    }
    
    private func migrateMeterSettingsIfNeeded() {
        guard sharedDataStore.meterSettings == nil else {
            return
        }
        
        if let standardDataStoreMeterSettings = standardDataStore.meterSettings {
            save(meterSettings: standardDataStoreMeterSettings)
            standardDataStore.removeMeterSettings()
        }
    }
}

private extension KeyValueStore {
    
    private static let jsonDecoder = JSONDecoder()
    private static let jsonEncoder = JSONEncoder()
    
    enum DataKeys: String {
        case meterSettings
    }
    
    var meterSettings: MeterSettings? {
        var decodedValue: MeterSettings?
        if let data = self.get(DataKeys.meterSettings.rawValue) as? Data {
            decodedValue = try? Self.jsonDecoder.decode(MeterSettings.self, from: data)
        }
        return decodedValue
    }
    
    func set(meterSettings: MeterSettings?) {
        let encodedValue = try? Self.jsonEncoder.encode(meterSettings)
        self.set(.init(key: DataKeys.meterSettings.rawValue, value: encodedValue))
    }
    
    func removeMeterSettings() {
        set(meterSettings: nil)
    }
}


// MARK: - Real instance

public extension MeterSettingsDataSource {
    
    static func real(appGroupName: String) -> MeterSettingsDataSource {
        .init(sharedDataStore: .shared(forAppGroupName: appGroupName),
              standardDataStore: .standard)
    }
}

// MARK: - Fake instance

#if DEBUG
public extension MeterSettingsDataSource {
    
    static let fake = MeterSettingsDataSource(
        sharedDataStore: .fake,
        standardDataStore: .fake
    )
}
#endif
