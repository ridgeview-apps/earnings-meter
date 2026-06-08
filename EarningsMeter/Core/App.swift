import DataStores
import Foundation
import PresentationViews
import SwiftUI

@main
struct AppScene: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        if ProcessInfo.resetUserPreferences {
            UserDefaults.sharedTargetStorage.resetPreferences()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootScreen()
                .appAnimationsEnabled(ProcessInfo.animationsEnabled)
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UserDefaults.sharedTargetStorage.migrateLegacyValuesIfNeeded()
        Font.registerCustomFonts()

        return true
    }
}
