struct DataServices {
    var meterSettings: MetterSettingsService
}

// MARK: - Real instance
extension DataServices {
    
    static let real = DataServices(meterSettings: .real)
}

// MARK: - Fake instance
#if DEBUG
extension DataServices {
    
    static let fake = DataServices(meterSettings: .fake)
}
#endif
