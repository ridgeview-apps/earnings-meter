import SwiftUI
import WidgetKit

final class ScenePhaseHandler {
        
    func scenePhaseChanged(to updatedPhase: ScenePhase) {
        switch updatedPhase {
        case .background:
            reloadWidgets()
        case .inactive:
            reloadWidgets()
        case .active:
            return
        @unknown default:
            return
        }
    }
    
    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
