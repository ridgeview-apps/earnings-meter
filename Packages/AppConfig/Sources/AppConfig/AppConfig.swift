import Foundation

public struct AppConfig {
    public let contactUsEmail: String
    public let appStoreProductUrl: URL
    public let appGroupName: String
    public let widgetOverlayTitle: String?
    
    public var submitAppReviewURL: URL {
        guard var urlComponents = URLComponents(string: appStoreProductUrl.absoluteString) else {
            return appStoreProductUrl
        }
        urlComponents.queryItems = [.init(name: "action", value: "write-review")]
        return urlComponents.url ?? appStoreProductUrl
    }
    
    public init(contactUsEmail: String,
                appStoreProductUrl: URL,
                appGroupName: String,
                widgetOverlayTitle: String?) {
        self.contactUsEmail = contactUsEmail
        self.appStoreProductUrl = appStoreProductUrl
        self.appGroupName = appGroupName
        self.widgetOverlayTitle = widgetOverlayTitle
    }
}

// MARK: - Real instance
public extension AppConfig {
    
    // Load config from build settings
    static func loadedFromInfoPlist(inBundle bundle: Bundle) -> AppConfig {
        let infoPlistValues = bundle.infoPlistValues(forKey: "appConfig")
        
        let appConfig = AppConfig(
            contactUsEmail: infoPlistValues["contactUsEmail"],
            appStoreProductUrl: infoPlistValues[url: "appStoreProductUrl"],
            appGroupName: infoPlistValues["appGroupName"],
            widgetOverlayTitle: infoPlistValues[safe: "widgetOverlayTitle"]
        )
        
        return appConfig
    }

}

// MARK: - Fake instance
#if DEBUG
public extension AppConfig {
    
    static let stub = AppConfig(contactUsEmail: "test@notanemail.com",
                                appStoreProductUrl: .fake,
                                appGroupName: "group.fake.earnings-meter",
                                widgetOverlayTitle: nil)
}
#endif

private extension URL {
    static let fake = URL(string: "https://httpbin.org")!
}
