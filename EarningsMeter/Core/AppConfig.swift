import Foundation
import Shared

struct AppConfig {
    
    let contactUsEmail: String
    let appStoreProductUrl: URL
    let appGroupName: String
    
    var submitAppReviewURL: URL {
        guard var urlComponents = URLComponents(string: appStoreProductUrl.absoluteString) else {
            return appStoreProductUrl
        }
        urlComponents.queryItems = [.init(name: "action", value: "write-review")]
        return urlComponents.url ?? appStoreProductUrl
    }
}


// MARK: - Shared instance

extension AppConfig {
    
    static let shared: AppConfig = {
        let config = Bundle.main.loadInfoPlistConfig(forKey: "appConfig")
        
        let appGroupName = config["appGroupName"]
        guard let sharedTargetDefaults = UserDefaults(suiteName: appGroupName) else {
            fatalError("Unable to load UserDefaults for app group name \(appGroupName)")
        }
        
        return AppConfig(
            contactUsEmail: config["contactUsEmail"],
            appStoreProductUrl: config[url: "appStoreProductUrl"],
            appGroupName: appGroupName
        )
    }()
}


// Default App Storage

extension UserDefaults {
    
    static let sharedTargetStorage: UserDefaults = {
        let appGroupName = AppConfig.shared.appGroupName
        guard let sharedTargetDefaults = UserDefaults(suiteName: appGroupName) else {
            fatalError("Unable to load UserDefaults for app group name \(appGroupName)")
        }
        return sharedTargetDefaults
    }()
}
