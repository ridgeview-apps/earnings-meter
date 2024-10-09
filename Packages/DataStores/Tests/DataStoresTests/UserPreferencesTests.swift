import Models
import ModelStubs
import Testing

@testable import DataStores

struct UserPreferencesTests {
    
    @Test
    func meterSettingsSetUpRequired() throws {
        let populatedUserPrefs = UserPreferences(meterSettings: ModelStubs.dayTime_0900_to_1700(),
                                                 earningsSinceDate: nil)
        let emptyUserPrefs = UserPreferences.empty
        
        #expect(!populatedUserPrefs.needsOnboarding)
        #expect(emptyUserPrefs.needsOnboarding)
    }
}
