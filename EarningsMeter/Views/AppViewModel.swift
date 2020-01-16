import Combine

//
// This is the app-wide source of truth and is available as an @EnvironmentObject throughout the app.
//
// Global state mutation is handled by triggering an input (e.g. inputs.refreshData.send) which are then mapped
// to outputs (e.g. @Published properties). The input-output mapping is all done in the init method via reactive
// streams.
//
final class AppViewModel: ObservableObject {

    let inputs = Inputs()
    let outputActions: OutputActions
    let environment: AppEnvironment
    
    // MARK: - State
    @Published var meterSettings: MeterSettings?
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(meterSettings: MeterSettings?,
         environment: AppEnvironment) {
        self.environment = environment
        
        let didRefreshData = inputs.refreshData
                                   .flatMap {
                                        _ in environment.services.meterSettings.load()
                                   }
        
        let didSaveSettings = inputs.saveMeterSettings
                                    .flatMap {
                                        environment.services.meterSettings.save(meterSettings: $0)
                                    }
        
        self.meterSettings = meterSettings
        
        self.outputActions = .init(
            didSaveMeterSettings: didSaveSettings.eraseToAnyPublisher(),
            didRefreshData: didRefreshData.eraseToAnyPublisher()
        )
        
        didRefreshData
            .assign(to: \.meterSettings, on: self, ownership: .weak)
            .store(in: &cancelBag)

        didSaveSettings
            .assign(to: \.meterSettings, on: self, ownership: .weak)
            .store(in: &cancelBag)
    }
    
    static func empty(with environment: AppEnvironment) -> AppViewModel {
        AppViewModel(meterSettings: nil, environment: environment)
    }
}

// MARK: - Inputs
extension AppViewModel {
    struct Inputs {
        let refreshData = PassthroughSubject<Void, Never>()
        let saveMeterSettings = PassthroughSubject<MeterSettings, Never>()
    }
}

// MARK: - Output actions
extension AppViewModel {
    
    struct OutputActions {
        let didSaveMeterSettings: AnyPublisher<MeterSettings?, Never>
        let didRefreshData: AnyPublisher<MeterSettings?, Never>
    }

}

#if DEBUG

extension AppViewModel {
    
    static func preview(meterSettings: MeterSettings? = nil) -> AppViewModel {
        .init(meterSettings: meterSettings, environment: .preview)
    }
    
}

#endif
