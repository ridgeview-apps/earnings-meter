import DataSources

struct AppDataSources {
    public var meterSettings: MeterSettingsDataSource
}

// MARK: - Real instance
extension AppDataSources {
    
    static func real(appGroupName: String) -> AppDataSources {
        .init(meterSettings: .real(appGroupName: appGroupName))
    }
}

// MARK: - Fake instance
#if DEBUG
extension AppDataSources {
    
    static let fake = AppDataSources(meterSettings: .fake)
}
#endif
