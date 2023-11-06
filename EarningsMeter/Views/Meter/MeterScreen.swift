import DataStores
import Models
import PresentationViews
import SwiftUI

struct MeterScreen: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var userPreferences: UserPreferencesDataStore
    
    let style: MeterView.Style
    let navigationTitle: LocalizedStringKey
    @State private var meterTimer: Timer?
    @State private var currentReading: MeterCalculator.Reading?
    @State private var accumulatedEarningsDateSelection: Date = .now
    private var savedMeterSettings: MeterSettings? { userPreferences.savedMeterSettings }
    
    var body: some View {
        ZStack {
            Color.adaptiveGreyOne
            meterView
                .padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle(navigationTitle)
        .onAppear {
            startMeter()
        }
        .onDisappear {
            stopMeter()
        }
        .onChange(of: savedMeterSettings) { _ in
            startMeter()
        }
        .onChange(of: accumulatedEarningsDateSelection) { newValue in
            userPreferences.save(accumulatedEarningsSince: newValue)
            startMeter()
        }
        .task {
            restoreUserSettings()
        }
    }
    
    @ViewBuilder private var meterView: some View {
        if let savedMeterSettings, let currentReading {
            MeterView(style: style,
                      settings: savedMeterSettings,
                      reading: currentReading,
                      accumulatedEarningsDateSelection: $accumulatedEarningsDateSelection)
        }
    }
    
    private func startMeter() {
        guard let savedMeterSettings else { return }
        
        stopMeter()
        let meterCalculator = MeterCalculator(meterSettings: savedMeterSettings)
        meterTimer = Timer.scheduledTimer(withTimeInterval: meterCalculator.meterSettings.defaultMeterSpeed,
                                          repeats: true) { _ in
            switch style {
            case .today:
                currentReading = meterCalculator.dailyReading(at: .now)
            case .accumulated:
                currentReading = meterCalculator.accumulatedReading(at: .now, since: accumulatedEarningsDateSelection)
            }
            
        }
        meterTimer?.fire()
    }
    
    private func stopMeter() {
        meterTimer?.invalidate()
        meterTimer = nil
    }
    
    private func restoreUserSettings() {
        if let savedDate = userPreferences.earningsSince {
            accumulatedEarningsDateSelection = savedDate
        }
    }
}


// MARK: - Previews
#if DEBUG
#Preview {
    MeterScreen(style: .today,
                navigationTitle: "Preview")
        .styledPreview()
        .environmentObject(UserPreferencesDataStore.stub(savedSettings: .placeholder))
        .withStubbedEnvironment()
}
#endif
