import PresentationViews
import RidgeviewCore
import SwiftUI

struct AppInfoScreen: View {
    
    @Environment(\.appEnvironment) var appEnvironment
    @Environment(\.locale) var locale
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            AppInfoView(appVersionNumber: Bundle.main.appVersionNumber,
                        appReviewURL: appEnvironment.submitAppReviewURL,
                        contactUs: .init(emailAddress: appEnvironment.contactUsEmail,
                                         appVersion: Bundle.main.appVersionNumber,
                                         appName: Bundle.main.appName,
                                         deviceInfo: Device.current.modelName,
                                         localeInfo: "\(locale.identifier) - \(locale.language.languageCode?.identifier ?? "")"),
                        appGroupName: appEnvironment.appGroupName)
            
            .navigationTitle(Text(.appInfoNavigationTitle))
            .withToolbarCloseButton(placement: .topBarLeading)
        }
    }
}

#Preview {
    AppInfoScreen()
}
