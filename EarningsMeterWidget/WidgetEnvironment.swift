import Foundation
import Shared

struct WidgetEnvironment {
    
    let appGroupName: String
    let widgetOverlayTitle: String?
    let userDefaults: UserDefaults
}

private final class WidgetBundleLocator {}

// MARK: - Instantiation

extension WidgetEnvironment {
    
    static let shared: WidgetEnvironment = {
        let bundle = Bundle(for: WidgetBundleLocator.self)
        let config = bundle.loadInfoPlistConfig(forKey: "widgetEnvironment")
        
        let appGroupName = config["appGroupName"]
        guard let sharedTargetDefaults = UserDefaults(suiteName: appGroupName) else {
            fatalError("Unable to load UserDefaults for app group name \(appGroupName)")
        }
        
        return WidgetEnvironment(
            appGroupName: config["appGroupName"],
            widgetOverlayTitle: config[safe: "widgetOverlayTitle"],
            userDefaults: sharedTargetDefaults
        )
    }()
    
    static let stub = WidgetEnvironment(
        appGroupName: "group.stub.app.group.name",
        widgetOverlayTitle: "Stub",
        userDefaults: .standard
    )
}
