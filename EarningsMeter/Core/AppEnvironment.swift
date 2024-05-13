import Foundation
import Shared

struct AppEnvironment {
    
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
    
    var userDefaults: UserDefaults? {
        guard let sharedTargetDefaults = UserDefaults(suiteName: appGroupName) else {
            assertionFailure("Unable to load UserDefaults for app group name \(appGroupName)")
            return nil
        }
        return sharedTargetDefaults
    }
}


// MARK: - Instantiation

extension AppEnvironment {
    
    static let shared: AppEnvironment = {
        let config = Bundle.main.loadInfoPlistConfig(forKey: "appEnvironment")
        
        return AppEnvironment(
            contactUsEmail: config["contactUsEmail"],
            appStoreProductUrl: config[url: "appStoreProductUrl"],
            appGroupName: config["appGroupName"]
        )
    }()
}
