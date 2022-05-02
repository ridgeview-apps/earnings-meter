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
    
    init(appViewModel: AppViewModel) {
        
        let onFirstAppearance = inputs.appear.first()
        
        // 1. Trigger a refresh on first appearance
        onFirstAppearance
            .sink { appViewModel.inputs.refreshData.send() }
            .store(in: &bag)
        
        let onFirstRefresh = appViewModel.outputActions.didRefreshData.first()
        
        // 2. When it's done, set up the initial child view state
        onFirstRefresh
            .map { meterSettings -> ChildViewState in
                meterSettings == nil ? .editSettings : .meterRunning
            }
            .assign(to: \.childViewState, on: self, ownership: .weak)
            .store(in: &bag)
        
        // 3. React to all other inputs
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
        let goToSettings = PassthroughSubject<Void, Never>()
        let closeSettings = PassthroughSubject<Void, Never>()
        let goToAppInfo = PassthroughSubject<Void, Never>()
        let closeAppInfo = PassthroughSubject<Void, Never>()
    }
}
