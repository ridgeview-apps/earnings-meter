import DataStores
import PresentationViews
import SwiftUI

@main
struct AppScene: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootScreen()
        }
    }
}
// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppEnvironment.shared.userDefaults.migrateLegacyValuesIfNeeded()
        Font.registerCustomFonts()
        
        return true
    }
}
