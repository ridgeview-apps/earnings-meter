import Foundation
import Shared

struct WidgetConfig {
    
    let appGroupName: String
    let widgetOverlayTitle: String?
    let userDefaults: UserDefaults
}

private final class WidgetBundleLocator {}

// MARK: - Instantiation

extension WidgetConfig {
    
    static let shared: WidgetConfig = {
        let bundle = Bundle(for: WidgetBundleLocator.self)
        let config = bundle.loadInfoPlistConfig(forKey: "widgetConfig")
        
        let appGroupName = config["appGroupName"]
        guard let sharedTargetDefaults = UserDefaults(suiteName: appGroupName) else {
            fatalError("Unable to load UserDefaults for app group name \(appGroupName)")
        }
        
        return WidgetConfig(
            appGroupName: config["appGroupName"],
            widgetOverlayTitle: config[safe: "widgetOverlayTitle"],
            userDefaults: sharedTargetDefaults
        )
    }()
    
    static let stub = WidgetConfig(
        appGroupName: "group.stub.app.group.name",
        widgetOverlayTitle: "Stub",
        userDefaults: .standard
    )
}
