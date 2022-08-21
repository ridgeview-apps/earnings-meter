import Combine
import Model

//
// This is the app-wide source of truth
//
// Global state mutation is handled by triggering an input (e.g. refreshData()) which are then mapped
// to outputs (e.g. @Published properties).
//
final class AppViewModel: ObservableObject {

    let environment: AppEnvironment
    
    // MARK: - State
    @Published var meterSettings: MeterSettings?
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(environment: AppEnvironment) {
        self.environment = environment
        environment.services.meterSettings.$meterSettings.assign(to: &$meterSettings)
    }
    
    func refreshData() {
        environment.services.meterSettings.load()
    }
    
    func save(meterSettings: MeterSettings) {
        environment.services.meterSettings.save(meterSettings: meterSettings)
    }    
}


#if DEBUG

extension AppViewModel {
    
    static func preview(meterSettings: MeterSettings? = nil) -> AppViewModel {
        .init(environment: .preview)
    }
    
}

#endif
