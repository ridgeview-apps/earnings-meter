//import XCTest
//import Combine
//@testable import Earnings_Meter

// SHILANTODO
//
//class RootViewModelTests: XCTestCase {
//
//    private var cancelBag = Set<AnyCancellable>()
//
//    override func setUp() {
//        super.setUp()
//        KeyValueStore.unitTestStorage = [String: Any]()
//    }
//
//    func testRootViewModel_appear_welcomeState() throws {
//
//        // Given
//        let keyValueStore = KeyValueStore.unitTest
//        var environment = AppEnvironment.unitTest
//        environment.services.meterSettings = .init(keyValueStore: keyValueStore)
//        let appViewModel = AppViewModel.empty(with: environment)
//
//        let viewModel = RootViewModel(appViewModel: appViewModel)
//
//        // When
//        viewModel.inputs.appear.send()
//
//        // Then
//        XCTAssertEqual(.settingsHome, viewModel.navigationState)
//        XCTAssertFalse(viewModel.isAppInfoPresented)
//    }
//
//    func testRootViewModel_appear_meterRunningState() throws {
//
//        // Given
//        let viewModel = setUpWithMeterRunning()
//
//        // Then
//        XCTAssertTrue(viewModel.navigationState == .meterHome())
//        XCTAssertFalse(viewModel.isAppInfoPresented)
//    }
//
//    func testRootViewModel_goToSettings() throws {
//
//        // Given
//        let viewModel = setUpWithMeterRunning()
//
//        // When
//        viewModel.inputs.goToSettings.send()
//
//        // Then
//        XCTAssertEqual(.settingsHome, viewModel.navigationState)
//        XCTAssertFalse(viewModel.isAppInfoPresented)
//    }
//
//    func testRootViewModel_closeSettings() throws {
//
//        // Given
//        let viewModel = setUpWithMeterRunning()
//
//        // When
//        viewModel.inputs.goToSettings.send()
//        XCTAssertEqual(.settingsHome, viewModel.navigationState)
//        viewModel.inputs.closeSettings.send()
//
//        // Then
//        XCTAssertEqual(.meterHome(, viewModel.navigationState)
//        XCTAssertFalse(viewModel.isAppInfoPresented)
//    }
//
//    func testRootViewModel_goToAppInfo() throws {
//
//        // Given
//        let viewModel = setUpWithMeterRunning()
//
//        // When
//        viewModel.inputs.goToAppInfo.send()
//
//        // Then
//        XCTAssertEqual(.meterHome, viewModel.navigationState)
//        XCTAssertTrue(viewModel.isAppInfoPresented)
//    }
//
//    func testRootViewModel_closeAppInfo() throws {
//
//        // Given
//        let viewModel = setUpWithMeterRunning()
//
//        // When
//        viewModel.inputs.goToAppInfo.send()
//        XCTAssertTrue(viewModel.isAppInfoPresented)
//        viewModel.inputs.closeAppInfo.send()
//
//        // Then
//        XCTAssertEqual(.meterHome, viewModel.navigationState)
//        XCTAssertFalse(viewModel.isAppInfoPresented)
//    }
//}
//
//extension RootViewModelTests {
//
//    func setUpWithMeterRunning() -> RootViewModel {
//
//        KeyValueStore.unitTestStorage["meterSettings"] = try? JSONEncoder().encode(MeterSettings.fake(ofType: .day_worker_0900_to_1700))
//
//        let keyValueStore = KeyValueStore.unitTest
//        var environment = AppEnvironment.unitTest
//        environment.services.meterSettings = .init(keyValueStore: keyValueStore)
//        let appViewModel = AppViewModel.fake(ofType: <#T##AppViewModel.FakeType#>)
//
//        let viewModel = RootViewModel(appViewModel: appViewModel)
//
//        viewModel.inputs.appear.send()
//
//        return viewModel
//    }
//}
//
//// TODO: refactor MeterSettingsService so that we don't need to hack KeyValueStore like this
//
//private extension KeyValueStore {
//
//    static var unitTestStorage = [String: Any]()
//    static var unitTest: KeyValueStore {
//
//        return KeyValueStore(
//            get: { key -> Any? in
//                unitTestStorage[key]
//            }, set: { pair in
//                unitTestStorage[pair.key] = [pair.value]
//            }
//        )
//    }
//}
