import Foundation

public struct AppConfig {
    public let contactUsEmail: String
    public let appStoreProductUrl: URL
    public let appGroupName: String
    
    public init(contactUsEmail: String,
                appStoreProductUrl: URL,
                appGroupName: String) {
        self.contactUsEmail = contactUsEmail
        self.appStoreProductUrl = appStoreProductUrl
        self.appGroupName = appGroupName
    }
}

// MARK: - Real instance
public extension AppConfig {
    
    // Load config from build settings
    static func loaded(fromBundle bundle: Bundle) -> AppConfig {
        let infoPlistValues = bundle.infoPlistValues(forKey: "appConfig")
        
        let appConfig = AppConfig(
            contactUsEmail: infoPlistValues["contactUsEmail"],
            appStoreProductUrl: infoPlistValues[url: "appStoreProductUrl"],
            appGroupName: infoPlistValues["appGroupName"]
        )
        
        return appConfig
    }

}

// MARK: - Fake instance
#if DEBUG
public extension AppConfig {
    
    static let fake = AppConfig(contactUsEmail: "test@notanemail.com",
                                appStoreProductUrl: .fake,
                                appGroupName: "group.fake.earnings-meter")
}
#endif

private extension URL {
    static let fake = URL(string: "https://httpbin.org")!
}
