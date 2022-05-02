import SwiftUI
import Combine

struct MeterView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let appViewModel: AppViewModel
    let onTappedSettings: () -> Void
    @StateObject private var viewModel: MeterViewModel
    
    init(appViewModel: AppViewModel,
         onTappedSettings: @escaping () -> Void = {}) {
        self.appViewModel = appViewModel
        self._viewModel = StateObject(wrappedValue: MeterViewModel(appViewModel: appViewModel))
        self.onTappedSettings = onTappedSettings
    }

    var body: some View {
        ZStack {
            Color.greyOne
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image(viewModel.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        meterContainerView
                    )
                    .padding([.leading, .trailing], 8)
                    .frame(maxWidth: 502)
            }
        }
        .onAppear {
            viewModel.inputs.appear.send()
        }
        .onDisappear(perform: viewModel.inputs.disappear.send)
        .onReceive(viewModel.outputActions.didTapSettings, perform: onTappedSettings)
        .navigationBarItems(trailing: settingsButton)
        .navigationTitle(viewModel.navigationTitleKey)
    }
    
    private var meterContainerView: some View {
        VStack {
            titleView
            Spacer(minLength: 12)
            VStack(spacing: 8) {
                MeterDigitsView(amount: viewModel.currentReading.amountEarned,
                                isEnabled: viewModel.currentReading.progress > 0,
                                formatter: .decimalStyle)
                hireStatusView
            }
            Spacer(minLength: 12)
            ProgressBarView(leftLabelText: viewModel.progressBarStartTimeText,
                            rightLabelText: viewModel.progressBarEndTimeText,
                            value: viewModel.currentReading.progress,
                            enabledTextColor: .white,
                            isEnabled: viewModel.currentReading.progress > 0)
                .frame(maxWidth: 500)

        }
        .padding([.top, .leading, .trailing],
                 horizontalSizeClass == .regular ? 40 : 20)
        .padding(.bottom,
                 horizontalSizeClass == .regular ? 70 : 45)
    }
    
    private var titleView: some View {
        Text(viewModel.headerTextKey)
            .font(.subheadline)
            .padding([.leading, .trailing], 20)
            .foregroundColor(.white)
    }
    
    private var hireStatusView: some View {
        HStack(spacing: 16) {
            ForEach(viewModel.statusPickerItems) { item in
                Text(item.textLocalizedKey)
                    .font(.headline)
                    .foregroundColor(item.isSelected ? .white : .disabledText)
                    .minimumScaleFactor(0.9)
            }
        }
    }
        
    private var settingsButton: some View {
        Button(action: viewModel.inputs.tapSettingsButton.send) {
            Image(systemName: "gear")
                .imageScale(.large)
                .padding([.top, .bottom, .leading])
        }
        .accentColor(Color.redThree)
    }
}

#if DEBUG
struct MeterView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MeterView(
                appViewModel: AppViewModel.fake(ofType: .meterRunningAtMiddleOfDay)
            )
                .embeddedInNavigationView()
                .previewDisplayName("iPhone 11 Pro (meter running)")
                .previewOption(deviceType: .iPhone_11_Pro)
            MeterView(appViewModel: AppViewModel.fake(ofType: .meterNotYetStarted))
                .embeddedInNavigationView()
                .previewDisplayName("iPhone 11 Pro (before work)")
                .previewOption(colorScheme: .dark)
                .previewOption(deviceType: .iPhone_11_Pro)
            MeterView(appViewModel: AppViewModel.fake(ofType: .meterFinished))
                .embeddedInNavigationView()
                .previewDisplayName("iPhone 11 Pro (after work)")
                .previewOption(deviceType: .iPhone_11_Pro)
            MeterView(appViewModel: AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewDisplayName("iPod")
                .previewOption(deviceType: .iPod_touch_7th_generation)
            MeterView(appViewModel: AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewOption(colorScheme: .dark)
            MeterView(appViewModel: AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewDisplayName("iPad")
                .previewOption(deviceType: .iPad_Pro_9_7_inch)
            MeterView(appViewModel: AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewLandscapeIPad()
                .previewDisplayName("Landscape iPad")
        }
//        .previewOption(locale: .fr) /* French language */
//        .previewOption(locale: .es) /*/ Spanish language */
//        .previewOption(contentSize: .extraExtraExtraLarge) /* XXL text */
    }
}
#endif
