import DataStores
import Models
import PresentationViews
import Shared
import SwiftUI

struct MeterScreen: View {
    
    // MARK: - Properties
    
    let style: MeterView.Style
    let navigationTitle: LocalizedStringResource
    
    @State private var meterTimer: Timer?
    @State private var selectedDate: Date = Self.defaultSelectionDate
    @State private var currentReading: MeterReading?
    
    @AppStorage(UserDefaults.Keys.userPreferences.rawValue, store: .sharedTargetStorage)
    private var userPreferences: UserPreferences = .empty
    
    private var savedMeterSettings: MeterSettings? { userPreferences.meterSettings }
    
    private static var defaultSelectionDate: Date { Calendar.current.startOfDay(for: .now) }
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.adaptiveGreyOne
            meterView
                .padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationTitle(Text(navigationTitle))
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
            userPreferences.earningsSinceDate = newValue
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
        meterTimer = Timer.scheduledTimer(withTimeInterval: savedMeterSettings.defaultMeterSpeed,
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
        if let earningsSince = userPreferences.earningsSinceDate {
            selectedDate = earningsSince
        }
    }
}


// MARK: - Previews
#Preview {
    MeterScreen(
        style: .today,
        navigationTitle: "Preview"
    )
    .styledPreview()
    .previewWithUserPreferences(UserPreferencesStubs.nineToFiveMeter)
}
