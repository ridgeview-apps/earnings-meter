import Combine

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
