import PresentationViews
import SwiftUI
import Shared

struct AppInfoScreen: View {

    @Environment(\.appConfig) var appConfig
    @Environment(\.locale) var locale
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            AppInfoView(
                appVersionNumber: Bundle.main.appVersionDisplayString ?? "",
                appReviewURL: appConfig.submitAppReviewURL,
                contactUs: .init(
                    emailAddress: appConfig.contactUsEmail,
                    appVersion: Bundle.main.appVersionDisplayString ?? "",
                    appName: Bundle.main.appName ?? "",
                    deviceInfo: Device.modelDescription,
                    localeInfo: "\(locale.identifier) - \(locale.language.languageCode?.identifier ?? "")"
                ),
                appGroupName: appConfig.appGroupName
            )

            .navigationTitle(Text(L10n.appInfoNavigationTitle))
            .withToolbarCloseButton(placement: .topBarLeading)
        }
    }
}

#Preview {
    AppInfoScreen()
}
