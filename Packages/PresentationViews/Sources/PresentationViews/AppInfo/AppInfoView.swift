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
    @State private var showCrashWarning = false
    
    public var body: some View {
        Form {
            Section {
                HStack {
                    Text("appInfo.app.version.title", bundle: .module)
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
                    Text("appInfo.contact.us.title", bundle: .module)
                }
                
                Link(destination: appReviewURL) {
                    Text("appInfo.rate.this.app.title", bundle: .module)
                }
            }
            if showDebugSection {
                Section(header: Text("Debug")) {
                    Button("Test crash reporting") {
                        showCrashWarning = true
                    }
                    HStack {
                        Text("App group")
                        Spacer()
                        Text(appGroupName)
                    }
                }
            }
        }
        .accentColor(Color.redThree)
        .alert("Are you sure?", isPresented: $showCrashWarning) {
            Button("Yes", role: .destructive) {
                fatalError("Crash report test")
            }
            Button("No", role: .cancel) {}
        }
    }
    
    private var emailSubject: String {
        String(format: localizedString("contact.us.subject %@"), contactUs.appName)
    }
    
    private var emailBody: String {
            """
            \(localizedString("contact.us.body.diagnostic.info"))
            
            \(localizedString("contact.us.body.app.version")): \(contactUs.appVersion)
            \(localizedString("contact.us.body.device.info")): \(contactUs.deviceInfo)
            \(localizedString("contact.us.body.locale.info")): \(contactUs.localeInfo)
            \(localizedString("contact.us.body.os.version")): \(osNameAndVersion)
            """
    }
    
    private var osNameAndVersion: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
    
    private func localizedString(_ key: String) -> String {
        NSLocalizedString(key, bundle: .module, comment: "")
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
