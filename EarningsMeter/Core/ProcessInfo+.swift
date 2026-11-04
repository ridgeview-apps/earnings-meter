import Foundation
import Shared

extension ProcessInfo {
    static var isRunningUITests: Bool {
        processInfo.environment[EarningsMeterUITestLaunchConfiguration.environmentKey] != nil
    }
}
