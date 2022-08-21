import Combine
import Model
import SwiftUI
import ViewComponents
import SharedViewStates

struct MeterHomeView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: MeterHomeViewModel
    
    let onTappedSettings: () -> Void
    
    
    // MARK: - Environment
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    
    init(
        viewModel: MeterHomeViewModel,
        onTappedSettings: @escaping () -> Void = {}
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.onTappedSettings = onTappedSettings
    }
    
    var body: some View {
        ZStack {
            Color.adaptiveGreyOne
            meterView
            .padding([.leading, .trailing], 16)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarItems(trailing: settingsButton)
        .navigationTitle("settings.navigation.title.meter")
        .onAppear(perform: viewModel.startMeterTimer)
        .onDisappear(perform: viewModel.stopMeterTimer)
    }
    
    private var meterView: some View {
        let viewState = MeterViewState(settings: viewModel.meterSettings,
                                       reading: viewModel.currentReading)
        
        return MeterView(isEnabled: viewState.isEnabled,
                         amountEarned: viewState.reading.amountEarned,
                         hireStatus: viewState.hireStatus,
                         workStartTimeText: viewState.startTimeText,
                         workEndTimeText: viewState.endTimeText,
                         progressBarValue: viewState.reading.progress)
    }
    
    private var settingsButton: some View {
        Button(action: onTappedSettings) {
            Image(systemName: "gear")
                .imageScale(.large)
                .padding([.top, .bottom, .leading])
        }
        .accentColor(Color.redThree)
    }
    
    private var hasCompactWidth: Bool { horizontalSizeClass == .compact }

}


// MARK: - Previews

//#if DEBUG
import ModelStubs

struct MeterHomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            beforeWork
        }
//        previewOnIPhoneAndIPad {
//            beforeWork.embeddedInNavigationView()
//            atWork.embeddedInNavigationView()
//            afterWork.embeddedInNavigationView()
//        }
//        .previewOption(locale: .en)
//        .previewOption(contentSize: .large)
//        .previewOption(colorScheme: .light)
    }
    
    static var beforeWork: MeterHomeView {
        MeterHomeView(
            viewModel: .init(
                meterSettings: .fake(ofType: .day_worker_0900_to_1700),
                now: { .weekday_0800_London }
            )
        )
    }
    
    static var atWork: MeterHomeView {
        MeterHomeView(
            viewModel: .init(
                meterSettings: .fake(ofType: .day_worker_0900_to_1700),
                now: { .weekday_1300_London }
            )
        )
    }
    
    static var afterWork: MeterHomeView {
        MeterHomeView(
            viewModel: .init(
                meterSettings: .fake(ofType: .day_worker_0900_to_1700),
                now: { .weekday_1900_London }
            )
        )
    }

}
//#endif
