import SwiftUI

struct AppInfoView: View {
    
    @ObservedObject private var viewModel: AppInfoViewModel
    @State private var showDebugSection = false
    private let onDone: () -> Void
    
    init(appViewModel: AppViewModel,
         onDone: @escaping () -> Void = { }) {
        viewModel = AppInfoViewModel(appViewModel: appViewModel)
        self.onDone = onDone
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("appInfo.app.version.title")
                    Spacer()
                    Text(viewModel.appVersionNumber)
                }
                .contentShape(Rectangle())
                .onTapGesture(count: 10) {
                    showDebugSection = true
                }
                
                MailButton("appInfo.contact.us.title",
                           to: [viewModel.contactUs.email],
                           subject: viewModel.contactUs.subject,
                           body: viewModel.contactUs.body)
                
                Link("appInfo.rate.this.app.title",
                     destination: viewModel.submitAppReviewURL)
            }
            if showDebugSection {
                Section(header: Text("Debug")) {
                    Button(action: viewModel.inputs.testCrashReporting.send) {
                        Text("Test crash reporting")
                    }
                }
            }
        }
        .accentColor(Color.redThree)
        .navigationTitle("appInfo.navigation.title")
        .navigationBarItems(trailing: doneButton)
        .onReceive(viewModel.outputActions.done, perform: onDone)
    }
    
    @ViewBuilder private var doneButton: some View {
        Button(action: viewModel.inputs.tapDone.send) {
            Text("button.done" )
        }
        .accentColor(Color.redThree)
    }
}

#if DEBUG
struct AppInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AppInfoView(appViewModel: .preview())
            .embeddedInNavigationView()
    }
}
#endif
