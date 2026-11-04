import DataStores
import Models
import PresentationViews
import Shared
import SwiftUI

struct MeterScreen: View {

    // MARK: - Properties

    let style: MeterView.Style

    @Environment(\.clock) private var clock

    @State private var meterTimer: Timer?
    /// `nil` until a date is picked or restored, so the default can come from the environment's clock.
    @State private var selectedDate: Date?
    @State private var currentReading: MeterReading?

    @AppStorage(UserDefaults.Keys.userPreferences.rawValue, store: .sharedTargetStorage)
    private var userPreferences: UserPreferences = .empty

    private var savedMeterSettings: MeterSettings? { userPreferences.meterSettings }

    /// The date accumulated earnings count from: the one picked, or else today.
    private var earningsSinceDate: Date { selectedDate ?? Calendar.current.startOfDay(for: clock.now) }

    private var navigationTitle: LocalizedStringResource {
        switch style {
        case .today:
            L10n.earningsTodayNavigationTitle
        case .accumulated:
            L10n.earningsSinceNavigationTitle
        }
    }


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
            MeterView(
                style: style,
                settings: savedMeterSettings,
                reading: currentReading,
                selectedDate: Binding(
                    get: { earningsSinceDate },
                    set: { selectedDate = $0 }
                )
            )
        }
    }

    private func startMeter() {
        guard let savedMeterSettings else { return }

        stopMeter()
        let meterCalculator = MeterCalculator(meterSettings: savedMeterSettings)
        let clock = clock
        meterTimer = Timer.scheduledTimer(
            withTimeInterval: savedMeterSettings.defaultMeterSpeed,
            repeats: true
        ) { _ in
            Task { @MainActor in
                switch style {
                case .today:
                    currentReading = meterCalculator.dailyReading(at: clock.now)
                case .accumulated:
                    currentReading = meterCalculator.accumulatedReading(at: clock.now, since: earningsSinceDate)
                }
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
        style: .today
    )
    .styledPreview()
    .previewWithUserPreferences(UserPreferencesStubs.nineToFiveMeter)
}
