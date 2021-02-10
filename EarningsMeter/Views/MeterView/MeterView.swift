import SwiftUI
import Combine

struct MeterView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel: MeterViewModel = .init()
    private(set) var onTappedSettings: () -> Void = {}

    var body: some View {
        ZStack {
            Color.redTwo
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
            viewModel.inputs.environmentObjects.send(appViewModel)
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
            Spacer()
            MeterDigitsView(amount: viewModel.currentReading.amountEarned,
                            isEnabled: viewModel.currentReading.progress > 0,
                            formatter: .decimalStyle)
            hireStatusView
            Spacer()
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
        HStack {
            Rectangle()
                .frame(height: 2)
            Text(viewModel.headerTextKey)
                .font(.subheadline)
                .layoutPriority(1)
            Rectangle()
                .frame(height: 2)
        }
        .padding([.leading, .trailing], 20)
        .foregroundColor(.white)
    }
    
    @State private var animateHireStatus: Bool = false
    private var hireStatusView: some View {
        HStack {
            ForEach(viewModel.statusPickerItems) { item in
                Text(item.textLocalizedKey)
                    .font(.headline)
                    .fontWeight(item.isSelected ? .bold : .light)
                    .foregroundColor(item.isSelected ? .white : .disabledText)
                    .minimumScaleFactor(0.9)
                    .padding(8)
                    .animation(nil)
                    .opacity(animateHireStatus && item.flashesWhenSelected ? 0.5 : 1)
                    .animation(animateHireStatus ? Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true) : nil)
            }
        }
        .onReceive(viewModel.$currentReading) { reading in
            animateHireStatus = reading.status == .atWork
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
            MeterView()
                .environmentObject(AppViewModel.fake(ofType: .meterRunningAtMiddleOfDay))
                .embeddedInNavigationView()
                .previewDisplayName("iPhone 11 Pro (meter running)")
                .previewOption(deviceType: .iPhone_11_Pro)
            MeterView()
                .environmentObject(AppViewModel.fake(ofType: .meterNotYetStarted))
                .embeddedInNavigationView()
                .previewDisplayName("iPhone 11 Pro (before work)")
                .previewOption(colorScheme: .dark)
                .previewOption(deviceType: .iPhone_11_Pro)
            MeterView()
                .environmentObject(AppViewModel.fake(ofType: .meterFinished))
                .embeddedInNavigationView()
                .previewDisplayName("iPhone 11 Pro (after work)")
                .previewOption(deviceType: .iPhone_11_Pro)
            MeterView()
                .environmentObject(AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewDisplayName("iPod")
                .previewOption(deviceType: .iPod_touch_7th_generation)
            MeterView()
                .environmentObject(AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewOption(colorScheme: .dark)
            MeterView()
                .environmentObject(AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewDisplayName("iPad")
                .previewOption(deviceType: .iPad_Pro_9_7_inch)
            MeterView()
                .environmentObject(AppViewModel.preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
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
