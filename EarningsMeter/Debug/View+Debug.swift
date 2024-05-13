import Models
import ModelStubs
import DataStores
import SwiftUI

extension View {
    
    func previewWithUserPreferences(_ userPreferences: UserPreferences?) -> some View {
        self
            .task {
                AppEnvironment.shared.userDefaults?.userPreferences = userPreferences
            }
    }
}

enum UserPreferencesStubs {    
    static var nineToFiveMeter: UserPreferences = UserPreferences(meterSettings: ModelStubs.dayTime_0900_to_1700(),
                                                                  earningsSinceDate: nil)
}
