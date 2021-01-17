import SwiftUI
import Combine

struct MeterView: View {
    
    @ObservedObject private var viewModel: MeterViewModel
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    private var onTappedSettings: () -> Void
    
    init(appViewModel: AppViewModel,
         onTappedSettings: @escaping () -> Void = {}) {
        viewModel = MeterViewModel(appViewModel: appViewModel)
        self.onTappedSettings = onTappedSettings
    }
    
    var body: some View {
        ZStack {
            Image(viewModel.backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(meterContainerView)
                .offset(y: -64)
                .padding([.leading, .trailing])
        }
        .onAppear(perform: viewModel.inputs.appear.send)
        .onDisappear(perform: viewModel.inputs.disappear.send)
        .onReceive(viewModel.outputActions.didTapSettings, perform: onTappedSettings)
        .navigationBarItems(trailing: settingsButton)
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    private var meterContainerView: some View {
        VStack {
            titleView
            Spacer()
            VStack(spacing: horizontalSizeClass == .regular ? 40 : 10) {
                MeterDigitsView(amount: viewModel.currentReading.amountEarned,
                                isEnabled: viewModel.currentReading.progress > 0,
                                formatter: .decimalStyle)
                    .animation(.none)
                hireStatusView
            }
            Spacer()
            ProgressBarView(leftLabelText: viewModel.progressBarStartTimeText,
                            rightLabelText: viewModel.progressBarEndTimeText,
                            value: viewModel.currentReading.progress,
                            enabledTextColor: .white,
                            fontSize: 4,
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
                .padding(.leading, 20)
            Text(viewModel.headerTextKey)
                .font(Font.body.smallCaps())
                .layoutPriority(1)
            Rectangle()
                .frame(height: 2)
                .padding(.trailing, 20)
        }
        .foregroundColor(.white)
    }
    
    private var hireStatusView: some View {
        HStack(spacing: 20) {
            ForEach(viewModel.hireStatusPickerItems) { item in
                Text(item.textLocalizedKey)
                    .font(Font.headline.smallCaps())
                    .fontWeight(item.isSelected ? .bold : .regular)
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
    }
}

#if DEBUG
struct MeterView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            MeterView(appViewModel: .preview(meterSettings: .fake(ofType: .weekdayOnlyMeter)))
                .embeddedInNavigationView()
            MeterView(appViewModel: .preview(meterSettings: .fake(ofType: .sevenDayMeter)))
                .embeddedInNavigationView()
            MeterView(appViewModel: .preview(meterSettings: .fake(ofType: .weekdayOnlyMeter)))
                .embeddedInNavigationView()
                .previewOption(colorScheme: .dark)
        }
    }
}
#endif
