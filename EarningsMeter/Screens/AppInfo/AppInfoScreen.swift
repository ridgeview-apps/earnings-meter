import PresentationViews
import RidgeviewCore
import SwiftUI

struct AppInfoScreen: View {
    
    @Environment(\.appConfig) var appConfig
    @Environment(\.locale) var locale
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            AppInfoView(appVersionNumber: Bundle.main.appVersionNumber,
                        appReviewURL: appConfig.submitAppReviewURL,
                        contactUs: .init(emailAddress: appConfig.contactUsEmail,
                                         appVersion: Bundle.main.appVersionNumber,
                                         appName: Bundle.main.appName,
                                         deviceInfo: Device.current.modelName,
                                         localeInfo: "\(locale.identifier) - \(locale.language.languageCode?.identifier ?? "")"),
                        appGroupName: appConfig.appGroupName)
            
            .navigationTitle(Text(.appInfoNavigationTitle))
            .withToolbarCloseButton(placement: .topBarLeading)
        }
    }
}

#Preview {
    AppInfoScreen()
}
