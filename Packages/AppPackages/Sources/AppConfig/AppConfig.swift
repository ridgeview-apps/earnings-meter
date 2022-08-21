import Foundation

public struct AppConfig {
    public let contactUsEmail: String
    public let appStoreProductUrl: URL
    public let appCenter: AppCenter
    public let appGroupName: String
    
    public init(contactUsEmail: String,
                appStoreProductUrl: URL,
                appCenter: AppConfig.AppCenter,
                appGroupName: String) {
        self.contactUsEmail = contactUsEmail
        self.appStoreProductUrl = appStoreProductUrl
        self.appCenter = appCenter
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
            appCenter: .init(
                appSecret: infoPlistValues["appCenterAppSecret"]
            ),
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
                                appCenter: .init(appSecret: "fakeAppCenterSecret"),
                                appGroupName: "group.fake.earnings-meter")
}
#endif

private extension URL {
    static let fake = URL(string: "https://httpbin.org")!
}

public extension AppConfig {
    
    struct AppCenter {
        public let appSecret: String
    }
}



/*
 
 import Foundation
 import RidgeviewCore

 struct AppConfig {
     
     let contactUsEmail: String
     let appStoreProductUrl: URL
     let appCenter: AppCenter
     let transportAPI: TransportAPI
 }

 // MARK: - Real instance
 extension AppConfig {
     
     // Load config from Main Info plist
     
     static let real: AppConfig = {
         let infoPlistValues = Bundle.main.infoPlistValues(forKey: "appConfig")
         
         let appConfig = AppConfig(
             contactUsEmail: infoPlistValues["contactUsEmail"],
             appStoreProductUrl: infoPlistValues[url: "appStoreProductUrl"],
             appCenter: .init(
                 appSecret: infoPlistValues["appCenterAppSecret"]
             ),
             transportAPI: .init(
                 baseURL: infoPlistValues[url: "transportAPIURL"],
                 appId: infoPlistValues["transportAPIAppId"],
                 appKey: infoPlistValues["transportAPIAppKey"]
             )
         )
         
         return appConfig
     }()

 }

 // MARK: - Fake instance
 #if DEBUG
 extension AppConfig {
     
     static let fake = AppConfig(contactUsEmail: "test@notanemail.com",
                                 appStoreProductUrl: .fake,
                                 appCenter: .init(appSecret: "fakeAppCenterSecret"),
                                 transportAPI: .init(baseURL: .fake,
                                                     appId: "fakeAPIAppId",
                                                     appKey: "fakeAPIAppKey"))
 }
 #endif

 private extension URL {
     static let fake = URL(string: "https://fakeurl.com")!
 }

 extension AppConfig {
     
     struct AppCenter {
         let appSecret: String
     }
     
     struct TransportAPI {
         let baseURL: URL
         let appId: String
         let appKey: String
     }
 }

 */
