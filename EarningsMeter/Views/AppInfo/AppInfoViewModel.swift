import Combine
import CombineExt
import DeviceKit
import Foundation

final class AppInfoViewModel: ObservableObject {
    
    let inputs = Inputs()
    let outputActions: OutputActions
    
    // MARK: - State
    let appVersionNumber: String
    let contactUs: ContactUs
    let submitAppReviewURL: URL
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(appViewModel: AppViewModel) {
        appVersionNumber = appViewModel.environment.mainBundle.appVersionNumber
        
        outputActions = OutputActions(
            done: inputs.tapDone.eraseToAnyPublisher()
        )
        
        contactUs = .init(email: appViewModel.environment.appConfig.contactUsEmail,
                          bundle: appViewModel.environment.mainBundle,
                          device: appViewModel.environment.currentDevice,
                          locale: appViewModel.environment.currentLocale,
                          localizer: appViewModel.environment.stringLocalizer)

        submitAppReviewURL = appViewModel.environment.appConfig.submitAppReviewUrl
                
        inputs
            .testCrashReporting
            .sink(receiveValue: DebugSettings.testCrashReporting)
            .store(in: &cancelBag)
    }
}

// MARK: - Inputs
extension AppInfoViewModel {
    struct Inputs {
        let testCrashReporting = PassthroughSubject<Void, Never>()
        let tapDone = PassthroughSubject<Void, Never>()
    }
}

// MARK: - Output actions
extension AppInfoViewModel {
    struct OutputActions {
        let done: AnyPublisher<Void, Never>
    }
}

extension AppInfoViewModel {
    
    struct ContactUs: Equatable {
        let email: String
        let subject: String
        let body: String
        
        static let empty: ContactUs = .init(email: "", subject: "", body: "")
    }
}

private extension AppInfoViewModel.ContactUs {
    
    init(email: String,
         bundle: Bundle,
         device: Device,
         locale: Locale,
         localizer: StringLocalizer) {
        self.email = email

        self.subject = "\(String(format: localizer.localized("contact.us.subject %@"), bundle.appName))"

        self.body =
        """


        \(localizer.localized("contact.us.body.diagnostic.info"))

        \(localizer.localized("contact.us.body.app.version")): \(bundle.appVersionNumber)
        \(localizer.localized("contact.us.body.device.info")): \(device)
        \(localizer.localized("contact.us.body.locale.info")): \(locale.identifier) - \(locale.languageCode ?? "")
        """
    }
}

private extension AppConfig {

    var submitAppReviewUrl: URL {
        var urlComponents = URLComponents(string: appStoreProductUrl.absoluteString)!
        urlComponents.queryItems = [.init(name: "action", value: "write-review")]
        return urlComponents.url!
    }
}
