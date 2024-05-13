import Models
import Foundation

public struct UserPreferences {
    
    public var meterSettings: MeterSettings?
    public var earningsSinceDate: Date?
    
    public init(meterSettings: MeterSettings?,
                earningsSinceDate: Date?) {
        self.meterSettings = meterSettings
        self.earningsSinceDate = earningsSinceDate
    }
    
    public var needsOnboarding: Bool { meterSettings == nil }
}

public extension UserPreferences {
    static let empty = UserPreferences(meterSettings: nil, earningsSinceDate: nil)
}


// MARK: - Codable

extension UserPreferences: Codable {
    
    enum CodingKeys: CodingKey {
        case meterSettings
        case earningsSinceDate
    }
    
    // N.B. Codable conformance needs to be implemented manually to play nicely with `RawRepresentable`
    // and prevent infinite recursion.
    //
    // See:
    // - https://stackoverflow.com/a/74191039
    // - https://antran.app/2024/appstorage_codable/

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.meterSettings = try container.decodeIfPresent(MeterSettings.self, forKey: .meterSettings)
        self.earningsSinceDate = try container.decodeIfPresent(Date.self, forKey: .earningsSinceDate)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.meterSettings, forKey: .meterSettings)
        try container.encodeIfPresent(self.earningsSinceDate, forKey: .earningsSinceDate)
    }
}

// MARK: - RawRepresentable (@AppStorage)

extension UserPreferences: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: RawValue) {
        guard
            let data = rawValue.data(using: .utf8),
            let decoded = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = decoded
    }
    
    public var rawValue: RawValue {
        guard
            let data = try? JSONEncoder().encode(self),
            let encodedValue = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        return encodedValue
    }
}
