import Foundation
import Shared

struct WidgetEnvironment {
    
    let appGroupName: String
    let widgetOverlayTitle: String?
}


// MARK: - Instantiation

extension WidgetEnvironment {
    
    static func shared(loadedFrom bundle: Bundle) -> WidgetEnvironment {
        let config = bundle.loadInfoPlistConfig(forKey: "widgetEnvironment")
        
        return WidgetEnvironment(
            appGroupName: config["appGroupName"],
            widgetOverlayTitle: config[safe: "widgetOverlayTitle"]
        )
    }
    
    var userDefaults: UserDefaults? {
        guard let sharedTargetDefaults = UserDefaults(suiteName: appGroupName) else {
            assertionFailure("Unable to load shared UserDefaults for app group name \(appGroupName)")
            return nil
        }
        return sharedTargetDefaults
    }
    
    static let stub = WidgetEnvironment(
        appGroupName: "group.stub.app.group.name",
        widgetOverlayTitle: "Stub"
    )
}
