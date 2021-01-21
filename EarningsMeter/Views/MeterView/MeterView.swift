import SwiftUI
import Combine

struct MeterView: View {
    
    @ObservedObject private var viewModel: MeterViewModel
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var onTappedSettings: () -> Void
    
    init(appViewModel: AppViewModel,
         onTappedSettings: @escaping () -> Void = {}) {
        self.viewModel = MeterViewModel(appViewModel: appViewModel)
        self.onTappedSettings = onTappedSettings
    }
    
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
            .onAppear(perform: viewModel.inputs.appear.send)
            .onDisappear(perform: viewModel.inputs.disappear.send)
        }
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
    
    private var hireStatusView: some View {
        HStack(spacing: 20) {
            ForEach(viewModel.hireStatusPickerItems) { item in
                Text(item.textLocalizedKey)
                    .font(.headline)
                    .fontWeight(item.isSelected ? .bold : .light)
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
            MeterView(appViewModel: .preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewOption(deviceType: .iPhone_11_Pro)
                .previewDisplayName("iPhone 11 Pro (meter running)")
            MeterView(appViewModel: .fake(ofType: .meterNotYetStarted))
                .embeddedInNavigationView()
                .previewOption(deviceType: .iPhone_11_Pro)
                .previewDisplayName("iPhone 11 Pro (before work)")
            MeterView(appViewModel: .fake(ofType: .meterFinished))
                .embeddedInNavigationView()
                .previewOption(deviceType: .iPhone_11_Pro)
                .previewDisplayName("iPhone 11 Pro (after work)")
            MeterView(appViewModel: .preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewOption(deviceType: .iPod_touch_7th_generation)
                .previewDisplayName("iPod")
            MeterView(appViewModel: .preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewOption(colorScheme: .dark)
            MeterView(appViewModel: .preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewOption(deviceType: .iPad_Pro_9_7_inch)
                .previewDisplayName("iPad")
            MeterView(appViewModel: .preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewLandscapeIPad()
                .previewDisplayName("Landscape iPad")
            MeterView(appViewModel: .preview(meterSettings: .fake(ofType: .day_worker_0900_to_1700)))
                .embeddedInNavigationView()
                .previewOption(contentSize: .extraExtraExtraLarge)
                .previewDisplayName("XXL Text")
        }
    }
}
#endif
