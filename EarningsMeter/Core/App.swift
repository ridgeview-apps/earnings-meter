import DataStores
import SwiftUI

@main
struct AppScene: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appModel = AppModel.real()
    
    var body: some Scene {
        WindowGroup {
            RootScreen()
                .environmentObject(appModel)
                .withEnvironmentObjects(userPreferences: appModel.userPreferences)
        }
    }
}
// MARK: - AppDelegate
import PresentationViews

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Font.registerCustomFonts()
        
        return true
    }
}


extension View {
    
    func withEnvironmentObjects(userPreferences: UserPreferencesDataStore) -> some View {
        self
            .environmentObject(userPreferences)
    }
}
