import DataStores
import Foundation
import PresentationViews
import Shared
import SwiftUI

@main
struct AppScene: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        UITestLaunch.configuration?.applyProcessSettings()
    }

    var body: some Scene {
        WindowGroup {
            RootScreen()
                .appAnimationsEnabled(!UITestLaunch.disablesAnimations)
                .environment(\.clock, UITestLaunch.clock)
                .environment(\.pausesRepeatingAnimations, ProcessInfo.isRunningUITests)
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
