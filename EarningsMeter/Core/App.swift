import DataStores
import SwiftUI

@main
struct AppScene: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var appModel = AppModel.real()
    
    var body: some Scene {
        WindowGroup {
            RootScreen()
                .environment(appModel)
                .withEnvironmentValues(userPreferences: appModel.userPreferences)
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
    
    func withEnvironmentValues(userPreferences: UserPreferencesDataStore) -> some View {
        self
            .environment(userPreferences)
    }
}
