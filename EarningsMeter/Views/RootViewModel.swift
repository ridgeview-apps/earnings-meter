import Foundation
import Combine

final class RootViewModel: ObservableObject {
    
    let inputs = Inputs()
    
    // MARK: - State
    enum ChildViewState: String {
        case editSettings
        case meterRunning
    }
    
    @Published var childViewState: ChildViewState = .editSettings
    @Published var isAppInfoPresented = false
    
    private var bag = [AnyCancellable]()
    
    init() {
        
        let appViewModel = inputs.envObjects

        let onFirstAppearance = inputs.appear.first()
        
        // 1. Trigger a refresh on first appearance
        onFirstAppearance
            .withLatestFrom(appViewModel)
            .sink { appViewModel in appViewModel.inputs.refreshData.send() }
            .store(in: &bag)
        
        let onFirstRefresh = appViewModel
                                .flatMap { $0.outputActions.didRefreshData.first() }
        
        // 2. When it's done, set up the initial child view state
        onFirstRefresh
            .map { meterSettings -> ChildViewState in
                meterSettings == nil ? .editSettings : .meterRunning
            }
            .assign(to: \.childViewState, on: self, ownership: .weak)
            .store(in: &bag)
        
        // 3. React to inputs
        inputs
            .goToSettings
            .assign(.editSettings, to: \.childViewState, on: self, ownership: .weak)
            .store(in: &bag)
        
        inputs
            .closeSettings
            .assign(.meterRunning, to: \.childViewState, on: self, ownership: .weak)
            .store(in: &bag)
        
        inputs
            .goToAppInfo
            .assign(true, to: \.isAppInfoPresented, on: self, ownership: .weak)
            .store(in: &bag)
        
        inputs
            .closeAppInfo
            .assign(false, to: \.isAppInfoPresented, on: self, ownership: .weak)
            .store(in: &bag)
    }
}

// MARK: - Inputs
extension RootViewModel {
    struct Inputs {
        let appear = PassthroughSubject<Void, Never>()
        let envObjects = PassthroughSubject<AppViewModel, Never>()
        let goToSettings = PassthroughSubject<Void, Never>()
        let closeSettings = PassthroughSubject<Void, Never>()
        let goToAppInfo = PassthroughSubject<Void, Never>()
        let closeAppInfo = PassthroughSubject<Void, Never>()
    }
}
