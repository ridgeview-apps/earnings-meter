import XCTest
import Combine
@testable import Earnings_Meter

class AppViewModelTests: XCTestCase {
    
    private var cancelBag = Set<AnyCancellable>()
    
    func testAppViewModel_refreshData() throws {
        // Given
        let viewModel = AppViewModel.fake(meterSettings: nil,
                                          environment: .unitTest)
        
        // When
        let didRefreshDataExpectation = expectation(description: "didRefreshData")
        
        viewModel.outputActions.didRefreshData.sink { _ in
            didRefreshDataExpectation.fulfill()
        }.store(in: &cancelBag)
        
        viewModel.inputs.refreshData.send()

        // Then
        wait(for: [didRefreshDataExpectation], timeout: 1.0)
    }
    
    func testAppViewModel_saveSettings() {
        // Given
        let viewModel = AppViewModel.fake(ofType: .welcomeState)
        
        // When
        let didSaveExpectation = expectation(description: "didSave")
        
        viewModel.outputActions.didSaveMeterSettings.sink { _ in
            didSaveExpectation.fulfill()
        }.store(in: &cancelBag)
        
        viewModel.inputs.saveMeterSettings.send(.fake(ofType: .day_worker_0900_to_1700))

        // Then
        wait(for: [didSaveExpectation], timeout: 1.0)
    }
}

