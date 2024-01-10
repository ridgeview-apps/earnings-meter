import DataStores
import PresentationViews
import Models
import WidgetKit

struct MeterTimeLineProvider: TimelineProvider {
    typealias Entry = MeterTimeLineEntry
    
    let userPreferences: UserPreferencesDataStore
    
    func placeholder(in context: Context) -> MeterTimeLineEntry {
        return .placeholder
    }
    
    // Called when a user is previewing the widget in the widget gallery or when the widget is in a transient state
    // (e.g. initial placement of the widget on screen)
    func getSnapshot(in context: Context, completion: @escaping (MeterTimeLineEntry) -> Void) {
        let snapshotEntry: MeterTimeLineEntry
        if context.isPreview {
            snapshotEntry = .placeholder
        } else {
            refreshUserPreferences()
            let calculator = MeterCalculator(meterSettings: userPreferences.savedMeterSettings ?? .placeholder)
            snapshotEntry = makeTimeLineEntry(at: .now, with: calculator)
        }
        completion(snapshotEntry)
    }
    
    // See: https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date
    //
    // Refreshes the widget by generating a timeline of events (i.e. points at which the widget will
    // re-render itself). Note: Apple restricts the number of "refreshes" (i.e. how often the method below
    // is called), NOT the number of timeline entries themselves.
    //
    func getTimeline(in context: Context, completion: @escaping (Timeline<MeterTimeLineEntry>) -> Void) {
        refreshUserPreferences()
        
        var entries: [MeterTimeLineEntry] = []
        let now = Date.now
        let calculator = MeterCalculator(meterSettings: userPreferences.savedMeterSettings ?? .placeholder)

        // 1. Generate a timeline entry for right now
        entries.append(makeTimeLineEntry(at: now, with: calculator))
        
        // 2. Generate 30 timeline entries (next 15 minutes, 2 per minute)
        let thirtySeconds = 30
        let firstScheduledEntry = now.roundedUp(toNearestSeconds: thirtySeconds)
        let fifteenMinutes = 15 * 60
        stride(from: 0, through: fifteenMinutes, by: thirtySeconds).forEach {
            if let readingTimestamp = Calendar.current.date(byAdding: .second, value: $0, to: firstScheduledEntry) {
                let scheduledEntry = makeTimeLineEntry(at: readingTimestamp, with: calculator)
                entries.append(scheduledEntry)
            }
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd) // Request a new timeline after the last entry has fired
        completion(timeline)
    }
    
    private func refreshUserPreferences() {
        userPreferences.refresh()
    }
    
    
    private func makeTimeLineEntry(at date: Date,
                                   with calculator: MeterCalculator) -> MeterTimeLineEntry {
        let reading = calculator.dailyReading(at: date)
        
        return MeterTimeLineEntry(date: date,
                                  reading: reading,
                                  meterSettings: calculator.meterSettings)
    }
}

struct MeterTimeLineEntry: TimelineEntry {
    let date: Date
    let reading: MeterCalculator.Reading
    let meterSettings: MeterSettings
    
    static let placeholder = MeterTimeLineEntry(date: .now,
                                                reading: .placeholder,
                                                meterSettings: .placeholder)
    
}


private extension Date {
    func roundedUp(toNearestSeconds numberOfSeconds: Int) -> Date {
        let roundedTimeInterval = (timeIntervalSinceReferenceDate / TimeInterval(numberOfSeconds)).rounded(.up) * TimeInterval(numberOfSeconds)
        return Date(timeIntervalSinceReferenceDate: roundedTimeInterval)
    }
}
