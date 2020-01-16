import XCTest
import Combine
@testable import Earnings_Meter

class RootViewModelTests: XCTestCase {
    
    private var cancelBag = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        KeyValueStore.unitTestStorage = [String: Any]()
    }
    
    func testRootViewModel_appear_welcomeState() throws {
        
        // Given
        let keyValueStore = KeyValueStore.unitTest
        var environment = AppEnvironment.unitTest
        environment.services.meterSettings = .init(keyValueStore: keyValueStore)
        let appViewModel = AppViewModel.empty(with: environment)
        
        let viewModel = RootViewModel()
        
        // When
        viewModel.inputs.envObjects.send(appViewModel)
        viewModel.inputs.appear.send()
        
        // Then
        XCTAssertEqual(.editSettings, viewModel.childViewState)
        XCTAssertFalse(viewModel.isAppInfoPresented)
    }
    
    func testRootViewModel_appear_meterRunningState() throws {
        
        // Given
        let viewModel = setUpWithMeterRunning()

        // Then
        XCTAssertEqual(.meterRunning, viewModel.childViewState)
        XCTAssertFalse(viewModel.isAppInfoPresented)
    }
    
    func testRootViewModel_goToSettings() throws {
        
        // Given
        let viewModel = setUpWithMeterRunning()

        // When
        viewModel.inputs.goToSettings.send()
        
        // Then
        XCTAssertEqual(.editSettings, viewModel.childViewState)
        XCTAssertFalse(viewModel.isAppInfoPresented)
    }
    
    func testRootViewModel_closeSettings() throws {
        
        // Given
        let viewModel = setUpWithMeterRunning()

        // When
        viewModel.inputs.goToSettings.send()
        XCTAssertEqual(.editSettings, viewModel.childViewState)
        viewModel.inputs.closeSettings.send()
        
        // Then
        XCTAssertEqual(.meterRunning, viewModel.childViewState)
        XCTAssertFalse(viewModel.isAppInfoPresented)
    }
    
    func testRootViewModel_goToAppInfo() throws {
        
        // Given
        let viewModel = setUpWithMeterRunning()

        // When
        viewModel.inputs.goToAppInfo.send()
        
        // Then
        XCTAssertEqual(.meterRunning, viewModel.childViewState)
        XCTAssertTrue(viewModel.isAppInfoPresented)
    }
    
    func testRootViewModel_closeAppInfo() throws {
        
        // Given
        let viewModel = setUpWithMeterRunning()

        // When
        viewModel.inputs.goToAppInfo.send()
        XCTAssertTrue(viewModel.isAppInfoPresented)
        viewModel.inputs.closeAppInfo.send()
        
        // Then
        XCTAssertEqual(.meterRunning, viewModel.childViewState)
        XCTAssertFalse(viewModel.isAppInfoPresented)
    }
}

extension RootViewModelTests {
    
    func setUpWithMeterRunning() -> RootViewModel {
        
        KeyValueStore.unitTestStorage["meterSettings"] = try? JSONEncoder().encode(MeterSettings.fake(ofType: .day_worker_0900_to_1700))
        
        let keyValueStore = KeyValueStore.unitTest
        var environment = AppEnvironment.unitTest
        environment.services.meterSettings = .init(keyValueStore: keyValueStore)
        let appViewModel = AppViewModel.empty(with: environment)
        
        let viewModel = RootViewModel()

        viewModel.inputs.envObjects.send(appViewModel)
        viewModel.inputs.appear.send()
        
        return viewModel
    }
}

// TODO: refactor MeterSettingsService so that we don't need to hack KeyValueStore like this

private extension KeyValueStore {
    
    static var unitTestStorage = [String: Any]()
    static var unitTest: KeyValueStore {

        return KeyValueStore(
            get: { key -> Any? in
                unitTestStorage[key]
            }, set: { pair in
                unitTestStorage[pair.key] = [pair.value]
            }
        )
    }
}
