import SwiftUI

@main
struct AppScene: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView(
                appViewModel: ProcessInfo.launchMode.appViewModel
            )
            .launchModeOverlay()
        }
    }
}

private extension AppLaunchMode {
    
    var appViewModel: AppViewModel {
        let appEnv: AppEnvironment
        
    #if DEBUG
        switch self {
        case .normal:
            appEnv = .real
        case .preview:
            appEnv = .preview
        case .unitTest:
            appEnv = .unitTest
        }
    #else
        appEnv = .real
    #endif
        
        return AppViewModel(meterSettings: nil, environment: appEnv)
    }
}

private extension View {
    func launchModeOverlay() -> some View {
        #if DEBUG
        if ProcessInfo.launchMode != .normal {
            return self.overlay(
                Text("\(ProcessInfo.launchMode.rawValue.uppercased()) MODE")
                    .font(.title)
            ).eraseToAnyView()
        }
        #endif
        
        return self.eraseToAnyView()
    }
}

// MARK: - AppDelegate
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        startServices()
        
        return true
    }
    
    private func startServices() {
        
    #if RELEASE_BUILD
        let config = AppConfig.real
        AppCenter.start(withAppSecret: config.appCenter.appSecret, services: [Analytics.self, Crashes.self])
    #endif
        
    }
    
}
