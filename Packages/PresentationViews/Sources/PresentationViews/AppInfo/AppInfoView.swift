import SwiftUI

public struct AppInfoView: View {
    
    public typealias ContactUs = AppInfo.ContactUs
    
    public let appVersionNumber: String
    public let appReviewURL: URL
    public let contactUs: ContactUs
    public let appGroupName: String
    
    public init(appVersionNumber: String,
                appReviewURL: URL,
                contactUs: ContactUs, 
                appGroupName: String) {
        self.appVersionNumber = appVersionNumber
        self.appReviewURL = appReviewURL
        self.contactUs = contactUs
        self.appGroupName = appGroupName
    }
    
    @State private var showDebugSection = false
    
    public var body: some View {
        Form {
            Section {
                HStack {
                    Text(.appInfoAppVersionTitle)
                    Spacer()
                    Text(appVersionNumber)
                }
                .contentShape(Rectangle())
                .onTapGesture(count: 10) {
                    showDebugSection = true
                }
                
                MailButton(to: [contactUs.emailAddress],
                           subject: emailSubject,
                           body: emailBody) {
                    Text(.appInfoContactUsTitle)
                }
                
                Link(destination: appReviewURL) {
                    Text(.appInfoRateThisAppTitle)
                }
            }
            if showDebugSection {
                Section {
                    HStack {
                        Text(.debugAppGroupTitle)
                        Spacer()
                        Text(appGroupName)
                    }
                } header: {
                    Text(.debugAppGroupHeader)
                }
            }
        }
        .accentColor(Color.redThree)
    }
    
    private var emailSubject: String {
        String(localized: .contactUsSubject(contactUs.appName))
    }
    
    private var emailBody: String {
            """
            \(String(localized: .contactUsBodyDiagnosticInfo))
            
            \(String(localized: .contactUsBodyAppVersion)): \(contactUs.appVersion)
            \(String(localized: .contactUsBodyDeviceInfo)): \(contactUs.deviceInfo)
            \(String(localized: .contactUsBodyLocaleInfo)): \(contactUs.localeInfo)
            \(String(localized: .contactUsBodyOsVersion)): \(osNameAndVersion)
            """
    }
    
    private var osNameAndVersion: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
}

#Preview {
    AppInfoView(
        appVersionNumber: "1.1.1",
        appReviewURL: URL(string: "https://www.google.com")!,
        contactUs: .empty,
        appGroupName: "group.foo.bar"
    )
}
