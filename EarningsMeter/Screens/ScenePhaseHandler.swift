import SwiftUI
import WidgetKit

final class ScenePhaseHandler {
        
    func scenePhaseChanged(to updatedPhase: ScenePhase) {
        switch updatedPhase {
        case .background:
            reloadWidgets()
        case .inactive:
            return
        case .active:
            return
        @unknown default:
            return
        }
    }
    
    func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
