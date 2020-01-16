import Foundation
import Combine

struct MetterSettingsService {

    private enum DataKeys: String {
        case meterSettings
    }
    
    let keyValueStore: KeyValueStore
    
    func load() -> AnyPublisher<MeterSettings?, Never> {
        var decodedSettings: MeterSettings?
        if let data = keyValueStore.get(DataKeys.meterSettings.rawValue) as? Data {
            decodedSettings = try? JSONDecoder().decode(MeterSettings.self, from: data)
        }
        return Just(decodedSettings).eraseToAnyPublisher()
    }
    
    func save(meterSettings: MeterSettings?) -> AnyPublisher<MeterSettings?, Never> {
        let encodedMeter = try? JSONEncoder().encode(meterSettings)
        keyValueStore.set(.init(key: DataKeys.meterSettings.rawValue, value: encodedMeter))
        return load()
    }
}

// MARK: - Real instance
extension MetterSettingsService {
    
    static let real = MetterSettingsService(keyValueStore: .real)
}

// MARK: - Fake instance
#if DEBUG
extension MetterSettingsService {
    
    static let fake = MetterSettingsService(keyValueStore: .fake)
}
#endif
