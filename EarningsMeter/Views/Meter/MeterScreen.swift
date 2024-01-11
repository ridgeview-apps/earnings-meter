import DataStores
import Models
import PresentationViews
import SwiftUI

struct MeterScreen: View {
    
    // MARK: - Properties
    
    @Environment(UserPreferencesDataStore.self) var userPreferences: UserPreferencesDataStore
    
    let style: MeterView.Style
    let navigationTitle: LocalizedStringKey
    @State private var meterTimer: Timer?
    @State private var currentReading: MeterCalculator.Reading?
    @State private var selectedDate: Date = Self.defaultSelectionDate
    private var savedMeterSettings: MeterSettings? { userPreferences.savedMeterSettings }
    
    private static var defaultSelectionDate: Date { Calendar.current.startOfDay(for: .now) }
    
    
    // MARK: - Body
    
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
        .onChange(of: savedMeterSettings) {
            startMeter()
        }
        .onChange(of: selectedDate) { _, newValue in
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
                      selectedDate: $selectedDate)
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
                currentReading = meterCalculator.accumulatedReading(at: .now, since: selectedDate)
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
            selectedDate = savedDate
        }
    }
}


// MARK: - Previews
#if DEBUG
#Preview {
    MeterScreen(style: .today,
                navigationTitle: "Preview")
        .styledPreview()
        .environment(UserPreferencesDataStore.stub(savedSettings: .placeholder))
        .withStubbedEnvironment()
}
#endif
