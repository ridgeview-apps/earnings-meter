import Foundation
import Shared

struct AppEnvironment {
    
    let contactUsEmail: String
    let appStoreProductUrl: URL
    let appGroupName: String
    let userDefaults: UserDefaults
    
    var submitAppReviewURL: URL {
        guard var urlComponents = URLComponents(string: appStoreProductUrl.absoluteString) else {
            return appStoreProductUrl
        }
        urlComponents.queryItems = [.init(name: "action", value: "write-review")]
        return urlComponents.url ?? appStoreProductUrl
    }
}


// MARK: - Instantiation

extension AppEnvironment {
    
    static let shared: AppEnvironment = {
        let config = Bundle.main.loadInfoPlistConfig(forKey: "appEnvironment")
        
        let appGroupName = config["appGroupName"]
        guard let sharedTargetDefaults = UserDefaults(suiteName: appGroupName) else {
            fatalError("Unable to load UserDefaults for app group name \(appGroupName)")
        }
        
        return AppEnvironment(
            contactUsEmail: config["contactUsEmail"],
            appStoreProductUrl: config[url: "appStoreProductUrl"],
            appGroupName: appGroupName,
            userDefaults: sharedTargetDefaults
        )
    }()
}
