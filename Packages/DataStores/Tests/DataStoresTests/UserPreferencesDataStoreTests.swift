import Models
import XCTest

@testable import DataStores

final class UserPreferencesDataStoreTests: XCTestCase {
    
    private lazy var userDefaultsSuiteName = String(describing: self)
    private lazy var userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)!
    
    override func setUp() {
        super.setUp()
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
    }
    
    override func tearDown() {
        super.tearDown()
        userDefaults.removePersistentDomain(forName: userDefaultsSuiteName)
    }

    func testReadMeterSettings_setUpRequired() throws {
        // Given
        let userPreferences = UserPreferencesDataStore.stub(userDefaults: userDefaults)
        
        // When
        let initialValue = userPreferences.savedMeterSettings
        
        // Then
        XCTAssertNil(initialValue)
        XCTAssertTrue(userPreferences.isSetUpRequired)
    }
    
    func testSaveMeterSettings() throws {
        // Given
        let userPreferences = UserPreferencesDataStore.stub(userDefaults: userDefaults)
        
        // When
        let nineToFiveMeter = ModelStubs.dayTime_0900_to_1700()
        userPreferences.save(meterSettings: nineToFiveMeter)
        
        // Then
        XCTAssertEqual(nineToFiveMeter, userPreferences.savedMeterSettings)
    }
}
