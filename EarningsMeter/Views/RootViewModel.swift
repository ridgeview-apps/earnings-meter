import Combine
import Foundation
import Model
import SwiftUI

final class RootViewModel: ObservableObject {
    
    // MARK: - State
    
    enum NavigationState: Equatable {
        case settingsHome
        case meterHome(MeterSettings)
    }
    
    @Published var navigationState: NavigationState = .settingsHome
    @Published var isAppInfoPresented = false
    
    private var bag = [AnyCancellable]()
    
    let appViewModel: AppViewModel
    
    private var initialFetchDone = false
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    
    // MARK: - Inputs
    
    func fetchInitialDataIfNeeded() {
        if !initialFetchDone {
            fetchData()
            initialFetchDone = true
        }
    }
    
    func fetchData() {
        appViewModel.refreshData()
        
        if let meterSettings = appViewModel.meterSettings {
            navigationState = .meterHome(meterSettings)
        } else {
            navigationState = .settingsHome
        }
    }
        
    func goToSettings() {
        navigationState = .settingsHome
    }
    
    func goToMeterHome() {
        guard let meterSettings = appViewModel.meterSettings else {
            return
        }
        navigationState = .meterHome(meterSettings)
    }
    
    func goToAppInfo() {
        isAppInfoPresented = true
    }
    
    func closeAppInfo() {
        isAppInfoPresented = false
    }
}
