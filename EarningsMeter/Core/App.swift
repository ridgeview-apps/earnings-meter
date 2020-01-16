import SwiftUI

@main
struct AppScene: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if CommandLine.isRunningUITests {
                uiTestLaunchView
            } else {
                RootView()
                    .environmentObject(ProcessInfo.launchMode.appViewModel)
                    .launchModeOverlay()
            }
        }
    }
    
    private var uiTestLaunchView: some View {
    #if DEBUG
        guard let rawValue = ProcessInfo.processInfo.environment["uiTestScenario"],
              let testScenario = UITestScenario(rawValue: rawValue) else {
            fatalError("Please set a test scenario before running your UI test")
        }
        return testScenario.launchView
    #else
        return EmptyView()
    #endif
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
        
        return AppViewModel.empty(with: appEnv)
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
        
    #if RELEASE_BUILD || ADHOC_BUILD
        let config = AppConfig.real
        AppCenter.start(withAppSecret: config.appCenter.appSecret, services: [Analytics.self, Crashes.self])
    #endif
        
    }
    
}
