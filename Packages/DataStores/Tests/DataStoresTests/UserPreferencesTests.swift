import Models
import ModelStubs
import XCTest

@testable import DataStores

final class UserPreferencesTests: XCTestCase {
    
    func testMeterSettingsSetUpRequired() throws {
        let populatedUserPrefs = UserPreferences(meterSettings: ModelStubs.dayTime_0900_to_1700(),
                                                 earningsSinceDate: nil)
        let emptyUserPrefs = UserPreferences.empty
        
        XCTAssertFalse(populatedUserPrefs.needsOnboarding)
        XCTAssertTrue(emptyUserPrefs.needsOnboarding)
    }
}
